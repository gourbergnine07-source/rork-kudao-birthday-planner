import { Link } from "react-router-dom";

import { KudaoMark, SiteLayout } from "@/components/SiteLayout";

const NotFound = () => {
  return (
    <SiteLayout>
      <div className="mx-auto flex w-full max-w-3xl flex-col items-center px-5 py-28 text-center">
        <KudaoMark className="h-14 w-14" />
        <h1 className="mt-8 text-balance text-4xl font-semibold tracking-tight">
          This page slipped our mind.
        </h1>
        <p className="mt-4 max-w-md leading-relaxed text-muted-foreground">
          Ironic, for an app about not forgetting things. The page you asked for is not here.
        </p>
        <Link
          to="/"
          className="mt-8 rounded-full bg-primary px-6 py-3 text-sm font-bold text-primary-foreground shadow-lg shadow-primary/25 transition-transform hover:-translate-y-0.5"
        >
          Back to the start
        </Link>
      </div>
    </SiteLayout>
  );
};

export default NotFound;
