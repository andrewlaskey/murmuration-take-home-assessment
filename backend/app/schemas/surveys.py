from typing import Any, List, Optional, Dict
from pydantic import BaseModel

class QuestionResponse(BaseModel):
    id: int
    age: int
    gender: str
    zip_code: str
    city: str
    state: str
    income: str
    education_level: str
    survey_name: str
    response: Any

class UploadResponse(BaseModel):
    status: str
    message: str
    records_processed: int
    errors: List[str]

class APISurveyResponse(BaseModel):
    id: int
    survey_name: str
    age: Optional[int]
    gender: Optional[str]
    zip_code: Optional[str]
    city: Optional[str]
    state: Optional[str]
    income: Optional[str]
    education_level: Optional[str]
    responses: Dict[str, Any]
    sentiment_label: Optional[str]