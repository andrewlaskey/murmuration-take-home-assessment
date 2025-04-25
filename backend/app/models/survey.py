from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class SurveyResponse(Base):
    __tablename__ = 'survey_responses'
    
    id = Column(Integer, primary_key=True)
    survey_name = Column(String(100), index=True)
    age = Column(Integer)
    gender = Column(String(50))
    zip_code = Column(String(10))
    city = Column(String(100))
    state = Column(String(2))
    income = Column(String(20))
    education_level = Column(String(50))
    responses = Column(JSONB)  # Stores all question responses
    sentiment_label = Column(String(20))
    
    def __repr__(self):
        return f"<SurveyResponse(id={self.id}, survey_name='{self.survey_name}', state='{self.state}')>"
    
    def to_dict(self):
        """Convert model instance to dictionary for API responses"""
        return {
            "id": self.id,
            "survey_name": self.survey_name,
            "age": self.age,
            "gender": self.gender,
            "zip_code": self.zip_code,
            "city": self.city,
            "state": self.state,
            "income": self.income,
            "education_level": self.education_level,
            "responses": self.responses,
            "sentiment_label": self.sentiment_label
        }
    
    def get_response(self, question_id):
        """Get a specific question response by ID"""
        if self.responses and question_id in self.responses:
            return self.responses[question_id]
        return None