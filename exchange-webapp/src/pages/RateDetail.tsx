import { useEffect, useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import { exchangeApi } from "../api";
import type { components } from "../generated/exchange-api";

type ExchangeRate = components["schemas"]["ExchangeRate"];

function formatAsOfDate(asOfDate: string): string {
  // asOfDate is a plain date (YYYY-MM-DD); parse as UTC so the displayed day
  // never shifts a day back/forward under the viewer's local timezone.
  const parsed = new Date(`${asOfDate}T00:00:00Z`);
  if (Number.isNaN(parsed.getTime())) return asOfDate;
  return new Intl.DateTimeFormat("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  }).format(parsed);
}

export default function RateDetail() {
  const { code = "" } = useParams<{ code: string }>();
  const location = useLocation();
  const navigate = useNavigate();
  const currencyName = (location.state as { name?: string } | null)?.name;

  const [rate, setRate] = useState<ExchangeRate | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    setRate(null);

    exchangeApi
      .GET("/currencies/{code}/rate", { params: { path: { code } } })
      .then(({ data, error: apiError, response }) => {
        if (cancelled) return;
        if (apiError || !data) {
          setError(
            response?.status === 404
              ? `No rate found for "${code}".`
              : "Could not load the exchange rate. Please try again.",
          );
          return;
        }
        setRate(data);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [code]);

  const backToSearch = () => navigate("/currencies");

  return (
    <div>
      <div className="navbar">ExchangeRate</div>
      <div className="page">
        <div className="breadcrumb">Currencies / {code}</div>

        {loading && <p className="status-text">Loading rate…</p>}

        {error && (
          <>
            <p className="error-text">{error}</p>
            <button className="button" onClick={backToSearch}>
              Back to search
            </button>
          </>
        )}

        {!loading && !error && rate && (
          <>
            <div className="row">
              <h1>
                1 {rate.currencyCode} = {rate.rateToUsd} USD
              </h1>
              <span className="badge info">Daily rate</span>
            </div>
            <p className="helper-text">
              Last updated: {formatAsOfDate(rate.asOfDate)}
            </p>
            <div className="card">
              Currency: {rate.currencyCode}
              {currencyName ? ` — ${currencyName}` : ""}
            </div>
            <div className="row">
              <span />
              <button className="button primary" onClick={backToSearch}>
                Back to search
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
