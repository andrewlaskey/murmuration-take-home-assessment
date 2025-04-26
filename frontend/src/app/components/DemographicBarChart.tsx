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

export interface DemographicBarChartProps {
  responses: QuestionResponse[];
  demoKey: string;
  title: string;
}

export default function DemographicBarChart({
  responses,
  demoKey,
  title,
}: DemographicBarChartProps) {
  const [summary, setSummary] = useState<{ name: string; total: number }[]>([]);

  useEffect(() => {
    const agg = responses.reduce((agg, response) => {
      if (Object.hasOwn(response, demoKey)) {
        const val = response[demoKey as keyof QuestionResponse];

        const category = agg.find((cat) => cat.name === val);

        if (category) {
          category.total++;
        } else {
          agg.push({
            name: `${val}`,
            total: 1,
          });
        }
      }

      return agg;
    }, [] as { name: string; total: number }[]);

    setSummary(agg);
    console.log(agg);
  }, [responses, demoKey]);

  return (
    <div>
      <h3 className="text-lg">{title}</h3>
      <ResponsiveContainer height={200}>
        <BarChart data={summary}>
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip labelStyle={{ color: "#0a0a0a" }} />
          <Bar dataKey="total" fill="#8884d8" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
