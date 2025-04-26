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

export interface RatingsByDemoProps {
  responses: QuestionResponse[];
  demoKey: string;
}

type RatingTotals = { rating: number } & Record<string, number>;

export default function RatingsByDemo({
  responses,
  demoKey,
}: RatingsByDemoProps) {
  const [summary, setSummary] = useState<RatingTotals[]>([]);
  const [categories, setCategories] = useState<Array<string | number>>([]);
  const [title, setTile] = useState<string>(demoKey);
  

  useEffect(() => {
    const agg = responses.reduce(
      (agg, response) => {
        if (Object.hasOwn(response, demoKey)) {
          const category = response[demoKey as keyof QuestionResponse];
          const rating = response.response;
          const ratingTotals = agg.find((totals) => totals.rating === rating);

          if (ratingTotals) {
            if (Object.hasOwn(ratingTotals, category)) {
              ratingTotals[category]++;
            } else {
              ratingTotals[category] = 1;
            }
          }
        }
        return agg;
      },
      [
        { rating: 1 },
        { rating: 2 },
        { rating: 3 },
        { rating: 4 },
        { rating: 5 },
      ] as RatingTotals[]
    );
    setSummary(agg);

    const cats = responses.reduce((agg, response) => {
      if (Object.hasOwn(response, demoKey)) {
        const category = response[demoKey as keyof QuestionResponse];
        agg.add(category);
      }
      return agg;
    }, new Set<string | number>());
    setCategories([...cats]);

    const capitalized = demoKey
      .replace(/_/g, " ")
      .split(" ")
      .map((word) => {
        if (word.length === 0) return "";
        return word[0].toUpperCase() + word.slice(1).toLowerCase();
      })
      .join(" ");
    setTile(capitalized);
      
  }, [responses, demoKey]);

  return (
    <div>
      <h3 className="text-lg">Rating Totals by {title}</h3>
      <ResponsiveContainer height={200}>
        <BarChart data={summary}>
          <XAxis dataKey="rating" />
          <YAxis />
          <Tooltip />
          {categories.map((category, index) => (
            <Bar dataKey={category} fill={COLORS[index]} />
          ))}
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
