import json
from typing import Any, Dict, Optional

from common import db


def _extract_name(event: Dict[str, Any]) -> Optional[str]:
    for container in (event.get("pathParameters"), event.get("queryStringParameters")):
        if container and container.get("name"):
            candidate = str(container["name"]).strip()
            if candidate:
                return candidate

    body = event.get("body")
    if body:
        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            payload = {}
        else:
            name = str(payload.get("name", "")).strip()
            if name:
                return name

    return None


def lambda_handler(event: Dict[str, Any], _context) -> Dict[str, Any]:
    name = _extract_name(event)
    if not name:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "The name to delete must be provided."}),
        }

    result = db.fetch_all(
        "DELETE FROM animals WHERE name = %s RETURNING name",
        (name,),
    )

    if not result:
        return {
            "statusCode": 404,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": f"Animal '{name}' not found."}),
        }

    return {
        "statusCode": 204,
        "headers": {"Content-Type": "application/json"},
        "body": "",
    }
