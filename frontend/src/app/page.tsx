import { getQuestionResponses } from "./lib/actions";
import QuestionResponseViewer from "./components/QuestionResponseViewer";

export default async function Home() {
  const responses = await getQuestionResponses(1);

  return (
    <div className="flex flex-col items-center w-auto">
      <h1 className="text-3xl font-bold my-8">Question Response Visualizer</h1>
      <QuestionResponseViewer initialId={1} initialResponses={responses}/>
    </div>
  );
}
