"""add users table

Revision ID: 0002
Revises: 0001
Create Date: 2026-05-05
"""
from alembic import op
import sqlalchemy as sa

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("google_sub", sa.String(100), nullable=False, unique=True),
        sa.Column("email", sa.String(200), nullable=False, unique=True),
        sa.Column("name", sa.String(200), nullable=True),
    )


def downgrade():
    op.drop_table("users")
