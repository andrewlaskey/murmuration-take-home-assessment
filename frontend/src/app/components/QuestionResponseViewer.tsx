"use client";

import { ChangeEvent, useEffect, useState } from "react";
import { QuestionResponse } from "../types/SurveyResponse";
import { getQuestionResponses } from "../lib/actions";
import RatingSummary from "./RatingSummary";
import DemographicBarChart from "./DemographicBarChart";

export default function QuestionResponseViewer({
  initialId,
  initialResponses,
}: {
  initialId: number;
  initialResponses: QuestionResponse[];
}) {
  const [questionId, setQuestionId] = useState(initialId);
  const [responses, setResponses] =
    useState<QuestionResponse[]>(initialResponses);
  const [isLoading, setIsLoading] = useState(false);
  const [questionType, setQuestionType] = useState<"rating" | "open" | null>(
    null
  );

  const updateQuestionTypeFromResponses = (
    responses: QuestionResponse[]
  ): void => {
    if (responses && responses.length > 0) {
      if (typeof responses[0].response === "number") {
        setQuestionType("rating");
      } else {
        setQuestionType("open");
      }
    }
  };

  useEffect(() => {
    if (initialResponses) {
      updateQuestionTypeFromResponses(initialResponses);
    }
  }, [initialResponses]);

  const handleIdChange = (e: ChangeEvent<HTMLInputElement>) => {
    const newId = parseInt(e.target.value, 10);

    setQuestionId(newId);
  };

  const handleUpdate = async () => {
    setIsLoading(true);
    const responses = await getQuestionResponses(questionId);

    setResponses(responses);
    updateQuestionTypeFromResponses(responses);
    setIsLoading(false);
  };

  return (
    <div className="w-full max-w-4xl mx-auto p-6 bg-white dark:bg-gray-900 rounded-lg shadow-md">
      <div className="mb-6 bg-gray-50 dark:bg-gray-800 p-4 rounded-md flex items-center space-x-3">
        <label className="flex items-">
          <span className="text-gray-700 dark:text-gray-300 font-medium block mr-4">
            Question ID:
          </span>
          <input
            type="number"
            name="id"
            value={questionId}
            onChange={handleIdChange}
            className="block w-16 border rounded-md border-gray-300 dark:border-gray-400 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 text-right"
          />
        </label>
        <button
          type="button"
          onClick={handleUpdate}
          className="px-4 py-2 bg-indigo-600 text-white font-medium rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 dark:focus:ring-offset-gray-900"
        >
          Update
        </button>
      </div>

      {isLoading && (
        <div className="flex justify-center items-center p-8">
          <div className="text-lg font-medium text-gray-500 dark:text-gray-400">
            Loading...
          </div>
        </div>
      )}

      {!isLoading && (
        <div className="space-y-2 mt-4">
          {questionType === "rating" && <RatingSummary responses={responses} />}
          <DemographicBarChart
            responses={responses}
            demoKey="gender"
            title="Gender"
          />
          <DemographicBarChart
            responses={responses}
            demoKey="income"
            title="Income"
          />
          <DemographicBarChart
            responses={responses}
            demoKey="education_level"
            title="Education Level"
          />
        </div>
      )}
    </div>
  );
}
