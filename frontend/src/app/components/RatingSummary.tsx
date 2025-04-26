"use client";
import {
  Bar,
  BarChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { QuestionResponse } from "../types/SurveyResponse";
import { useEffect, useState } from "react";
import { COLORS } from "../utils/constants";

export default function RatingSummary({
  responses,
}: {
  responses: QuestionResponse[];
}) {
  const [summary, setSummary] = useState<{ key: number; total: number }[]>([]);

  useEffect(() => {
    const agg = responses.reduce(
      (agg, response) => {
        const ratingTotal = agg.find((rt) => rt.key === response.response);

        if (ratingTotal) {
          ratingTotal.total++;
        }

        return agg;
      },
      [
        { key: 1, total: 0 },
        { key: 2, total: 0 },
        { key: 3, total: 0 },
        { key: 4, total: 0 },
        { key: 5, total: 0 },
      ]
    );

    setSummary(agg);
  }, [responses]);

  return (
    <div>
      <h3 className="text-lg">Rating Totals</h3>
      <ResponsiveContainer height={200}>
        <BarChart data={summary}>
          <XAxis dataKey="key" />
          <YAxis />
          <Tooltip />
          <Bar dataKey="total" fill={COLORS[1]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
