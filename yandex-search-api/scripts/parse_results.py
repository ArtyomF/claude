#!/usr/bin/env python3
"""
parse_results.py — разбирает XML-ответ Yandex Search API (после base64-декодирования)
и выводит чистый JSON-список результатов: позиция, домен, url, заголовок.

Использование:
  echo "<base64-строка>" | python3 parse_results.py
  или
  python3 parse_results.py --file rawdata.b64

Вывод — JSON в stdout, чтобы легко комбинировать с jq дальше по пайплайну.
"""
import sys
import base64
import json
import re
import argparse
import xml.etree.ElementTree as ET


def strip_hlwords(text: str) -> str:
    """Убирает теги <hlword>...</hlword>, оставляя только текст (жирный текст в выдаче Яндекса)."""
    if text is None:
        return ""
    return re.sub(r"</?hlword>", "", text)


def parse_yandex_xml(xml_text: str):
    root = ET.fromstring(xml_text)
    results = []
    position = 0

    # Структура: response/results/grouping/group/doc
    for group in root.iter("group"):
        for doc in group.findall("doc"):
            position += 1
            url_el = doc.find("url")
            domain_el = doc.find("domain")
            title_el = doc.find("title")

            title_text = ""
            if title_el is not None:
                # title может содержать вложенные <hlword> теги — соберём весь текст рекурсивно
                title_text = "".join(title_el.itertext())

            results.append({
                "position": position,
                "domain": domain_el.text if domain_el is not None else None,
                "url": url_el.text if url_el is not None else None,
                "title": title_text.strip(),
            })

    # Общее число найденных документов, если есть в ответе
    found_el = root.find(".//found[@priority='all']")
    total_found = int(found_el.text) if found_el is not None and found_el.text else None

    return {"total_found": total_found, "results": results}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", help="Файл с base64-строкой (иначе читаем stdin)")
    args = parser.parse_args()

    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            b64_data = f.read().strip()
    else:
        b64_data = sys.stdin.read().strip()

    if not b64_data:
        print(json.dumps({"error": "Пустой ввод — нет base64-данных для разбора"}), file=sys.stderr)
        sys.exit(1)

    try:
        xml_bytes = base64.b64decode(b64_data)
        xml_text = xml_bytes.decode("utf-8", errors="replace")
    except Exception as e:
        print(json.dumps({"error": f"Не удалось декодировать base64: {e}"}), file=sys.stderr)
        sys.exit(1)

    try:
        parsed = parse_yandex_xml(xml_text)
    except ET.ParseError as e:
        print(json.dumps({"error": f"Не удалось распарсить XML: {e}"}), file=sys.stderr)
        sys.exit(1)

    print(json.dumps(parsed, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
