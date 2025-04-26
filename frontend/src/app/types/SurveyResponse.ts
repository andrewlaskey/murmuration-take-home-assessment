export type Income = "Low" | "High" | "Lower-Middle" | "Upper-Middle";
export type EducationLevel =
  | "High School"
  | `Bachelor's Degree`
  | "Doctorate"
  | "Some College"
  | "Associate Degree"
  | `Master's Degree`;

export interface QuestionResponse {
  id: number;
  age: number;
  gender: string;
  zip_code: string;
  city: string;
  state: string;
  income: Income;
  education_level: EducationLevel;
  survey_name: string;
  response: string | number;
}
