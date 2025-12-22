
from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship
from pydantic import BaseModel


class Message(BaseModel):
    detail: str

class FriendExpenseLink(SQLModel, table=True):
    friend_id: int = Field(foreign_key="friend.id", primary_key=True)
    expense_id: int = Field(foreign_key="expense.id", primary_key=True)
    amount: float = Field(default=0, ge=0)

    friend: "Friend" = Relationship(back_populates="expense_links")
    expense: "Expense" = Relationship(back_populates="friend_links")

class Friend(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    expense_links: List[FriendExpenseLink] = Relationship(back_populates="friend", cascade_delete=True)
    credit_balance: float = Field(default=0, ge=0)
    debit_balance: float = Field(default=0, ge=0)

    def __repr__(self) -> str:
        return f"<Friend {self.id}: {self.name}>"

class Expense(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    description: str = Field(index=True)
    date: str
    amount: float = Field(default=0, ge=0)
    credit_balance: float = Field(default=0, ge=0)
    num_friends: int = Field(default=1, ge=1)
    friend_links: List[FriendExpenseLink] = Relationship(back_populates="expense", cascade_delete=True)

    def __repr__(self) -> str:
        return f"<Expense {self.id}: {self.description}>"

class FriendExpense(BaseModel):
    id: int
    description: str
    amount: float
    num_friends: int
    credit_balance: float
    debit_balance: float


