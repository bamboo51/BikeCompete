"""tasks and user stats

Revision ID: 0003
Revises: 0002
Create Date: 2026-05-05
"""
from alembic import op
import sqlalchemy as sa

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("total_points", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("users", sa.Column("total_distance_m", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("users", sa.Column("total_time_seconds", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("users", sa.Column("current_streak", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("users", sa.Column("longest_streak", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("users", sa.Column("last_activity_date", sa.Date(), nullable=True))

    op.create_table(
        "random_tasks",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("points", sa.Integer(), nullable=False),
        sa.Column("task_type", sa.String(50), nullable=False),
        sa.Column("target_value", sa.Integer(), nullable=False),
    )

    op.create_table(
        "daily_tasks",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("title", sa.String(200), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("points", sa.Integer(), nullable=False),
        sa.Column("task_type", sa.String(50), nullable=False),
        sa.Column("target_value", sa.Integer(), nullable=False),
    )

    op.create_table(
        "user_daily_tasks",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("daily_task_id", sa.Integer(), sa.ForeignKey("daily_tasks.id"), nullable=False),
        sa.Column("assigned_date", sa.Date(), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("progress_distance", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("progress_time", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("completed_at", sa.DateTime(), nullable=True),
    )


def downgrade():
    op.drop_table("user_daily_tasks")
    op.drop_table("daily_tasks")
    op.drop_table("random_tasks")
    for col in ["total_points", "total_distance_m", "total_time_seconds",
                "current_streak", "longest_streak", "last_activity_date"]:
        op.drop_column("users", col)
