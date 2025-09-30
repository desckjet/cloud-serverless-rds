import json
from decimal import Decimal
from typing import Any, Dict

from common import db


def _decimal_to_float(value: Any) -> Any:
    if isinstance(value, Decimal):
        return float(value)
    return value


def lambda_handler(event: Dict[str, Any], _context) -> Dict[str, Any]:  # noqa: D401
    records = db.fetch_all(
        "SELECT name, weight, height FROM animals ORDER BY name ASC"
    )

    payload = [
        {key: _decimal_to_float(val) for key, val in record.items()}
        for record in records
    ]

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"items": payload}),
    }
