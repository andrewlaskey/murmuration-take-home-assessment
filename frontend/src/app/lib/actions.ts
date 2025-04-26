"use server";
import { QuestionResponse } from "../types/SurveyResponse";

export async function getQuestionResponses(
  questionId: number
): Promise<QuestionResponse[]> {
  const apiUrl = process.env.API_URL || process.env.NEXT_PUBLIC_API_URL;

  if (apiUrl) {
    try {
      const data = await fetch(`${apiUrl}/api/v1/questions/${questionId}`);
      const responses = await data.json();

      return responses as QuestionResponse[];
    } catch (error) {
      console.error(error);
      return [];
    }
  }

  return [];
}
