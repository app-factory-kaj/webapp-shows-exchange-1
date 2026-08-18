import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { exchangeApi } from "../api";
import type { components } from "../generated/exchange-api";

type Currency = components["schemas"]["Currency"];

const PAGE_SIZE = 50;

export default function CurrencyPicker() {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const [currencies, setCurrencies] = useState<Currency[]>([]);
  const [count, setCount] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const requestId = useRef(0);

  useEffect(() => {
    const id = ++requestId.current;
    setLoading(true);
    setError(null);

    const timer = setTimeout(async () => {
      const { data, error: apiError } = await exchangeApi.GET("/currencies", {
        params: {
          query: {
            limit: PAGE_SIZE,
            offset: 0,
            ...(query.trim() ? { search: query.trim() } : {}),
          },
        },
      });

      if (requestId.current !== id) return; // a newer request superseded this one

      if (apiError || !data) {
        setError("Could not load currencies. Please try again.");
        setCurrencies([]);
        setCount(0);
        setHasMore(false);
      } else {
        setCurrencies(data.data);
        setCount(data.count);
        setHasMore(Boolean(data.next));
      }
      setLoading(false);
    }, 250);

    return () => clearTimeout(timer);
  }, [query]);

  const loadMore = async () => {
    const { data, error: apiError } = await exchangeApi.GET("/currencies", {
      params: {
        query: {
          limit: PAGE_SIZE,
          offset: currencies.length,
          ...(query.trim() ? { search: query.trim() } : {}),
        },
      },
    });

    if (!apiError && data) {
      setCurrencies((prev) => [...prev, ...data.data]);
      setHasMore(Boolean(data.next));
    }
  };

  const goToRate = (currency: Currency) => {
    navigate(`/currencies/${encodeURIComponent(currency.code)}/rate`, {
      state: { name: currency.name },
    });
  };

  return (
    <div>
      <div className="navbar">ExchangeRate</div>
      <div className="page">
        <div className="row">
          <h1>Find a currency</h1>
          <input
            className="search-input"
            type="search"
            placeholder="Search currency code or name…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            aria-label="Search currency code or name"
          />
        </div>
        <p className="helper-text">
          Pick a currency to see its current exchange rate to USD.
        </p>

        {loading && currencies.length === 0 && (
          <p className="status-text">Loading currencies…</p>
        )}
        {error && <p className="error-text">{error}</p>}

        {!error && !loading && currencies.length === 0 && (
          <p className="status-text">No currencies match "{query}".</p>
        )}

        {currencies.length > 0 && (
          <>
            <table className="currency-table">
              <thead>
                <tr>
                  <th>Code</th>
                  <th>Currency</th>
                </tr>
              </thead>
              <tbody>
                {currencies.map((currency) => (
                  <tr key={currency.code} onClick={() => goToRate(currency)}>
                    <td>{currency.code}</td>
                    <td>{currency.name}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <p className="status-text">
              Showing {currencies.length} of {count}
            </p>
            {hasMore && (
              <div className="load-more">
                <button className="button" onClick={loadMore}>
                  Load more
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
