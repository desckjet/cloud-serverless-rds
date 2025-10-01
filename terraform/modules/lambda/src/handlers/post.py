import json
from decimal import Decimal, InvalidOperation
from typing import Any, Dict

from common import db


class ValidationError(Exception):
    """Raised when incoming payload is not usable."""


REQUIRED_FIELDS = ("name", "weight", "height")


def _parse_payload(event: Dict[str, Any]) -> Dict[str, Any]:
    body = event.get("body")
    if body is None:
        raise ValidationError("Request body is required")

    try:
        payload = json.loads(body)
    except json.JSONDecodeError as exc:
        raise ValidationError("Body must be valid JSON") from exc

    missing = [field for field in REQUIRED_FIELDS if field not in payload]
    if missing:
        raise ValidationError(f"Missing required fields: {', '.join(missing)}")

    try:
        weight = Decimal(str(payload["weight"]))
        height = Decimal(str(payload["height"]))
    except (InvalidOperation, TypeError) as exc:
        raise ValidationError("Weight and height must be numeric") from exc

    name = str(payload["name"]).strip()
    if not name:
        raise ValidationError("Name must be a non-empty string")

    return {
        "name": name,
        "weight": weight,
        "height": height,
    }


def lambda_handler(event: Dict[str, Any], _context) -> Dict[str, Any]:
    try:
        payload = _parse_payload(event)
    except ValidationError as exc:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": str(exc)}),
        }

    db.execute(
        """
        INSERT INTO animals (name, weight, height)
        VALUES (%s, %s, %s)
        ON CONFLICT (name) DO UPDATE
            SET weight = EXCLUDED.weight,
                height = EXCLUDED.height
        """,
        (payload["name"], payload["weight"], payload["height"]),
    )

    response_item = {key: (float(val) if isinstance(val, Decimal) else val) for key, val in payload.items()}

    return {
        "statusCode": 201,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Animal saved", "item": response_item}),
    }
