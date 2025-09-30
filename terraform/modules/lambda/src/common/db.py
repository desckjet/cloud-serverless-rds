import os
import ssl
from functools import lru_cache
from typing import Any, Dict, Iterable, List, Optional

import boto3
from botocore.exceptions import BotoCoreError, ClientError
import pg8000


class DatabaseError(Exception):
    """Raised when database connectivity or credentials fail."""


_SSL_CONTEXT = ssl.create_default_context()
_RDS_CLIENT = boto3.client("rds")


@lru_cache(maxsize=1)
def _region() -> str:
    region = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION")
    if not region:
        raise DatabaseError("AWS region environment variable is not set")
    return region


def _generate_auth_token(host: str, port: int, username: str) -> str:
    try:
        return _RDS_CLIENT.generate_db_auth_token(
            DBHostname=host,
            Port=port,
            DBUsername=username,
            Region=_region(),
        )
    except (ClientError, BotoCoreError) as exc:  # pragma: no cover
        raise DatabaseError(f"Failed to generate IAM auth token: {exc}") from exc


def _connection_kwargs() -> Dict[str, Any]:
    host = os.environ["DB_HOST"]
    port = int(os.getenv("DB_PORT", "5432"))
    username = os.environ["DB_USERNAME"]

    return {
        "user": username,
        "password": _generate_auth_token(host, port, username),
        "host": host,
        "port": port,
        "database": os.environ["DB_NAME"],
        "ssl_context": _SSL_CONTEXT,
    }


def fetch_all(query: str, parameters: Optional[Iterable[Any]] = None) -> List[Dict[str, Any]]:
    return _execute(query, parameters, fetch=True)


def execute(query: str, parameters: Optional[Iterable[Any]] = None) -> None:
    _execute(query, parameters, fetch=False)


def _execute(query: str, parameters: Optional[Iterable[Any]], *, fetch: bool) -> List[Dict[str, Any]]:
    connection = pg8000.connect(**_connection_kwargs())

    try:
        results: List[Dict[str, Any]] = []

        with connection.cursor() as cursor:
            if parameters is None:
                cursor.execute(query)
            else:
                cursor.execute(query, parameters)

            if fetch:
                column_names = [column[0] for column in cursor.description]
                rows = cursor.fetchall()
                results = [dict(zip(column_names, row)) for row in rows]

        connection.commit()
        return results
    finally:
        connection.close()
