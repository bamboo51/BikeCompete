"""initial schema

Revision ID: 0001
Revises:
Create Date: 2026-05-05
"""
from alembic import op
import sqlalchemy as sa

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "teams",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
    )
    op.create_table(
        "riders",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("team_id", sa.Integer(), sa.ForeignKey("teams.id"), nullable=True),
    )
    op.create_table(
        "races",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(200), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("location", sa.String(200), nullable=True),
    )
    op.create_table(
        "results",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("rider_id", sa.Integer(), sa.ForeignKey("riders.id"), nullable=False),
        sa.Column("race_id", sa.Integer(), sa.ForeignKey("races.id"), nullable=False),
        sa.Column("position", sa.Integer(), nullable=True),
        sa.Column("finish_time_seconds", sa.Integer(), nullable=True),
    )


def downgrade():
    op.drop_table("results")
    op.drop_table("races")
    op.drop_table("riders")
    op.drop_table("teams")
