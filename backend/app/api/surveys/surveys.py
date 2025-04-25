from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List
import tempfile
import os
import pandas as pd

from app.database import get_db
from app.models.survey import SurveyResponse
from app.schemas.surveys import QuestionResponse, UploadResponse, APISurveyResponse

router = APIRouter()

@router.get("/surveys/", response_model=List[APISurveyResponse])
def read_surveys(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    responses = db.query(SurveyResponse).offset(skip).limit(limit).all()
    return responses

@router.get("/surveys/{survey_name}", response_model=APISurveyResponse)
def read_survey_by_name(survey_name: str, db: Session = Depends(get_db)):
    response = db.query(SurveyResponse).filter(SurveyResponse.survey_name == survey_name).first()
    if response is None:
        raise HTTPException(status_code=404, detail="Survey not found")
    return response

@router.get("/questions/{question_id}", response_model=List[QuestionResponse])
def read_responses_by_question(question_id: int, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    question_key = f"q{question_id}"

    responses = db.query(SurveyResponse).filter(SurveyResponse.responses.has_key(question_key)).offset(skip).limit(limit).all()

    return [{
        "id": r.id,
        "survey_name": r.survey_name,
        "age": r.age,
        "gender": r.gender,
        "zip_code": r.zip_code,
        "city": r.city,
        "state": r.state,
        "income": r.income,
        "education_level": r.education_level,
        "response": r.responses.get(question_key)
    } for r in responses]

@router.post("/upload", response_model=UploadResponse)
async def upload_csv(
    file: UploadFile = File(...), 
    survey_name: str = Form(...),
    db: Session = Depends(get_db)
):
    if not file.filename.endswith('.csv'):
        raise HTTPException(
            status_code=400, 
            detail="Only CSV files are accepted"
        )
    
    with tempfile.NamedTemporaryFile(delete=False, suffix='.csv') as temp_file:
        temp_file.write(await file.read())
        temp_file_path = temp_file.name
    
    try:
        records_processed = 0
        errors = []

        df = pd.read_csv(temp_file_path)
        df.columns = [col.strip().lower() for col in df.columns]

        non_question_cols = ['age', 'gender', 'zip_code', 'city', 'state', 'income', 'education_level', 'sentiment_label']
        question_cols = [col for col in df.columns if col not in non_question_cols]
        
        for _, row in df.iterrows():
            try:
                responses = {}
                for question in question_cols:
                    if pd.notna(row[question]):
                        question_key = question.split('_')[0]
                        responses[question_key] = row[question]
                
                survey_response = SurveyResponse(
                    survey_name=survey_name,
                    age=int(row['age']) if pd.notna(row['age']) else None,
                    gender=row['gender'] if pd.notna(row['gender']) else None,
                    zip_code=row['zip_code'] if pd.notna(row['zip_code']) else None,
                    city=row['city'] if pd.notna(row['city']) else None,
                    state=row['state'] if pd.notna(row['state']) else None,
                    income=row['income'] if pd.notna(row['income']) else None,
                    education_level=row['education_level'] if pd.notna(row['education_level']) else None,
                    responses=responses,
                    sentiment_label=row.get('sentiment_label', None)
                )

                db.add(survey_response)
                records_processed += 1
            except Exception as e:
                errors.append(f"Error processing row {records_processed + 1}: {str(e)}")
        
        db.commit()

        return {
            "status": "success",
            "message": f"Survey '{survey_name}' data uploaded successfully",
            "records_processed": records_processed,
            "errors": errors
        }
    except Exception as e:
        db.rollback()

        raise HTTPException(
            status_code=500,
            detail=f"Error processing file: {str(e)}"
        )
    finally:
        os.unlink(temp_file_path)