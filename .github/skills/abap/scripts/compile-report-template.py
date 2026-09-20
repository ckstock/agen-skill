#!/usr/bin/env python3
"""Compile the user's Excel report template into an ABAP report skeleton.

The script intentionally has two modes:

* new-report: Excel/JSON is the source of truth and an ABAP skeleton is emitted.
* maintenance: the existing ABAP source is the source of truth. The workbook is
  normalized into a review plan, but the source is never rewritten automatically.

Only Python's standard library is required. This keeps the helper usable on a
developer workstation without installing openpyxl.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from pathlib import Path
from typing import Any, Iterable
from xml.etree import ElementTree as ET


NS = {"x": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
      "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships"}


def clean(value: Any) -> str:
    return re.sub(r"\s+", " ", str(value or "").strip())


def slug(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]", "_", value).strip("_").lower()


def abap_name(value: str, fallback: str) -> str:
    value = re.sub(r"[^A-Za-z0-9_]", "_", clean(value)).upper()
    return value or fallback


class XlsxReader:
    """Small XLSX reader for plain value tables, without third-party packages."""

    def __init__(self, path: Path) -> None:
        self.path = path
        self.archive = zipfile.ZipFile(path)
        self.shared = self._shared_strings()
        self.sheets = self._sheet_map()

    def _shared_strings(self) -> list[str]:
        try:
            root = ET.fromstring(self.archive.read("xl/sharedStrings.xml"))
        except KeyError:
            return []
        values: list[str] = []
        for item in root.findall("x:si", NS):
            values.append("".join(node.text or "" for node in item.iter("{%s}t" % NS["x"])))
        return values

    def _sheet_map(self) -> dict[str, str]:
        workbook = ET.fromstring(self.archive.read("xl/workbook.xml"))
        rels = ET.fromstring(self.archive.read("xl/_rels/workbook.xml.rels"))
        relation_map = {
            rel.attrib["Id"]: rel.attrib["Target"]
            for rel in rels
        }
        result: dict[str, str] = {}
        for sheet in workbook.findall("x:sheets/x:sheet", NS):
            target = relation_map[sheet.attrib[f"{{{NS['r']}}}id"]]
            if not target.startswith("xl/"):
                target = "xl/" + target.lstrip("/")
            result[clean(sheet.attrib["name"])] = target
        return result

    def rows(self, name: str) -> list[list[str]]:
        actual = next((key for key in self.sheets if key == name or name in key), None)
        if actual is None:
            return []
        root = ET.fromstring(self.archive.read(self.sheets[actual]))
        result: list[list[str]] = []
        for row in root.findall("x:sheetData/x:row", NS):
            cells: dict[int, str] = {}
            for cell in row.findall("x:c", NS):
                ref = cell.attrib.get("r", "")
                match = re.match(r"([A-Z]+)", ref)
                if not match:
                    continue
                column = 0
                for char in match.group(1):
                    column = column * 26 + ord(char) - 64
                value = cell.find("x:v", NS)
                text = value.text if value is not None and value.text else ""
                if cell.attrib.get("t") == "s" and text:
                    text = self.shared[int(text)]
                inline = cell.find("x:is/x:t", NS)
                if inline is not None:
                    text = inline.text or ""
                cells[column] = clean(text)
            if cells:
                result.append([cells.get(index, "") for index in range(1, max(cells) + 1)])
        return result


def row_dicts(rows: list[list[str]]) -> list[dict[str, str]]:
    header_index = next(
        (index for index, row in enumerate(rows)
         if any("屏幕字段" in value or "字段名" in value or "参照字段" in value for value in row)),
        None,
    )
    if header_index is None:
        return []
    headers = [clean(value) for value in rows[header_index]]
    return [
        {headers[index]: clean(value) for index, value in enumerate(row) if index < len(headers) and headers[index]}
        for row in rows[header_index + 1:]
        if any(clean(value) for value in row)
    ]


def first(item: dict[str, str], *names: str) -> str:
    for name in names:
        for key, value in item.items():
            if name in key:
                return clean(value)
    return ""


def truthy(value: str) -> bool:
    return clean(value).upper() in {"X", "Y", "YES", "TRUE", "是", "必填"}


def parse_workbook(path: Path) -> dict[str, Any]:
    reader = XlsxReader(path)
    selection_rows = row_dicts(reader.rows("选择屏幕"))
    output_rows = row_dicts(reader.rows("自定义表"))
    if not output_rows:
        output_rows = row_dicts(reader.rows("报表字段"))

    selection = []
    for item in selection_rows:
        name = first(item, "屏幕字段", "字段名")
        if not name:
            continue
        selection.append({
            "name": abap_name(name, "P_FIELD"),
            "refTable": first(item, "可参照的表", "参考表", "参照表").upper(),
            "refField": first(item, "可参照字段", "参考字段", "参照字段").upper(),
            "required": truthy(first(item, "必填")),
            "kind": first(item, "单值", "范围").upper() or "P",
            "text": first(item, "描述", "字段描述"),
            "default": first(item, "默认值"),
        })

    fields = []
    for item in output_rows:
        name = first(item, "字段名", "输出字段", "字段")
        if not name:
            continue
        fields.append({
            "name": abap_name(name, "FIELD"),
            "refTable": first(item, "可参照的表", "参考表", "参照表").upper(),
            "refField": first(item, "可参照字段", "参考字段", "参照字段").upper(),
            "text": first(item, "描述", "字段描述"),
        })

    return {
        "source": str(path),
        "selection": selection,
        "fields": fields,
        "controls": {
            "selection": True,
            "count": True,
            "rowColor": True,
            "cellColor": True,
            "editStyle": True,
        },
        "logic": reader.rows("取数逻辑"),
        "buttons": reader.rows("按钮设置"),
        "classifications": reader.rows("分类信息"),
    }


def load_spec(path: Path) -> dict[str, Any]:
    if path.suffix.lower() in {".xlsx", ".xlsm"}:
        return parse_workbook(path)
    return json.loads(path.read_text(encoding="utf-8"))


def render_new_report(spec: dict[str, Any]) -> str:
    program = abap_name(spec.get("program", "z_template_report"), "Z_TEMPLATE_REPORT")
    line_type = abap_name(spec.get("lineType", "ty_data"), "TY_DATA").lower()
    table_name = clean(spec.get("dbTable", "MARA")).upper()
    fields = spec.get("fields", [])
    controls = spec.get("controls", {})
    lines: list[str] = [
        f"REPORT {program}.",
        "",
        "TYPES:",
        f"  BEGIN OF {line_type},",
    ]
    if controls.get("selection", True):
        lines.append("    sel        TYPE char1,")
    if controls.get("count", True):
        lines.append("    count      TYPE i,")
    if controls.get("rowColor", True):
        lines.append("    line_color TYPE c LENGTH 4,")
    if controls.get("cellColor", True):
        lines.append("    cell_color TYPE lvc_t_scol,")
    if controls.get("editStyle", True):
        lines.append("    cellstyles TYPE lvc_t_styl,")
    lines.append(f"    INCLUDE STRUCTURE {table_name.lower()},")
    for field in fields:
        name = abap_name(field.get("name", ""), "FIELD").lower()
        ref_table = clean(field.get("refTable", "")).lower()
        ref_field = clean(field.get("refField", "")).lower()
        if name and ref_table and ref_field and name != ref_field:
            lines.append(f"    {name} TYPE {ref_table}-{ref_field},")
    lines += [
        f"  END OF {line_type}.",
        "",
        f"DATA gt_data TYPE STANDARD TABLE OF {line_type}.",
        "DATA gt_fieldcat TYPE lvc_t_fcat.",
        "DATA gs_fieldcat TYPE lvc_s_fcat.",
        "DATA gs_layout TYPE lvc_s_layo.",
        "",
    ]
    for item in spec.get("selection", []):
        name = abap_name(item.get("name", ""), "P_FIELD").lower()
        ref_table = clean(item.get("refTable", "")).lower()
        ref_field = clean(item.get("refField", "")).lower()
        text = clean(item.get("text", "")) or name
        if item.get("kind", "P") == "S":
            lines.append(f"SELECT-OPTIONS s_{name} FOR {ref_table}-{ref_field}. \" {text}")
        else:
            lines.append(f"PARAMETERS p_{name} TYPE {ref_table}-{ref_field}. \" {text}")
    if spec.get("selection"):
        lines.append("")
    lines += [
        "START-OF-SELECTION.",
        "  \" TODO: implement the data retrieval rules from the 取数逻辑 sheet.",
        "  PERFORM frm_set_layout.",
        "  PERFORM frm_set_fieldcat.",
        "  PERFORM frm_display.",
        "",
        "FORM frm_set_layout.",
        "  CLEAR gs_layout.",
        "  gs_layout-cwidth_opt = abap_true.",
    ]
    if controls.get("selection", True):
        lines.append("  gs_layout-sel_mode = 'D'.")
        lines.append("  gs_layout-box_fname = 'SEL'.")
    if controls.get("count", True):
        lines.append("  gs_layout-countfname = 'COUNT'.")
    if controls.get("rowColor", True):
        lines.append("  gs_layout-info_fname = 'LINE_COLOR'.")
    if controls.get("cellColor", True):
        lines.append("  gs_layout-ctab_fname = 'CELL_COLOR'.")
    if controls.get("editStyle", True):
        lines.append("  gs_layout-stylefname = 'CELLSTYLES'.")
    lines += ["ENDFORM.", "", "FORM frm_set_fieldcat.", "  CLEAR gt_fieldcat."]
    for field in fields:
        name = abap_name(field.get("name", ""), "FIELD")
        ref_table = clean(field.get("refTable", "")).upper()
        ref_field = clean(field.get("refField", "")).upper()
        text = clean(field.get("text", "")) or name
        lines.append(f"  PERFORM set_fieldcat USING '{ref_table}' '{ref_field}' '{name}' '{text}'.")
    lines += [
        "ENDFORM.",
        "",
        "FORM set_fieldcat USING VALUE(p_ref_table) VALUE(p_ref_field) VALUE(p_fieldname) VALUE(p_text).",
        "  CLEAR gs_fieldcat.",
        "  gs_fieldcat-ref_table = p_ref_table.",
        "  gs_fieldcat-ref_field = p_ref_field.",
        "  gs_fieldcat-fieldname = p_fieldname.",
        "  gs_fieldcat-coltext = p_text.",
        "  gs_fieldcat-seltext = p_text.",
        "  APPEND gs_fieldcat TO gt_fieldcat.",
        "ENDFORM.",
        "",
        "FORM frm_display.",
        "  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'",
        "    EXPORTING",
        "      i_callback_program = sy-repid",
        "      is_layout_lvc = gs_layout",
        "      it_fieldcat_lvc = gt_fieldcat",
        "    TABLES",
        "      t_outtab = gt_data.",
        "ENDFORM.",
    ]
    return "\n".join(lines) + "\n"


def make_maintenance_plan(spec: dict[str, Any], source: Path) -> dict[str, Any]:
    text = source.read_text(encoding="utf-8", errors="replace")
    return {
        "mode": "maintenance",
        "source": str(source),
        "program": next((match.upper() for match in re.findall(r"^\s*REPORT\s+(\w+)", text, re.I | re.M)), ""),
        "sourceLineCount": len(text.splitlines()),
        "requestedSelection": spec.get("selection", []),
        "requestedFields": spec.get("fields", []),
        "requestedButtons": spec.get("buttons", []),
        "action": "review-only",
        "reason": "运维改代码保留源程序结构；生成器不自动重排或覆盖现有 ABAP。",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Compile Excel/JSON report definitions into ABAP.")
    parser.add_argument("--mode", choices=("new-report", "maintenance"), required=True)
    parser.add_argument("--input", required=True, help="XLSX/XLSM template or JSON spec")
    parser.add_argument("--output", required=True, help="ABAP output or maintenance-plan JSON")
    parser.add_argument("--source", help="Existing ABAP source; required in maintenance mode")
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)
    spec = load_spec(input_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if args.mode == "new-report":
        output_path.write_text(render_new_report(spec), encoding="utf-8")
    else:
        if not args.source:
            parser.error("--source is required in maintenance mode")
        plan = make_maintenance_plan(spec, Path(args.source))
        output_path.write_text(json.dumps(plan, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Generated {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
