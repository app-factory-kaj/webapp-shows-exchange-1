import { HashRouter, Routes, Route, Navigate } from "react-router-dom";
import CurrencyPicker from "./pages/CurrencyPicker";
import RateDetail from "./pages/RateDetail";

// HashRouter avoids needing any nginx rewrite config for deep links, and
// keeps every path root-relative (no `base`) as this app is served at its
// own gateway hostname's root.
export default function App() {
  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/currencies" replace />} />
        <Route path="/currencies" element={<CurrencyPicker />} />
        <Route path="/currencies/:code/rate" element={<RateDetail />} />
        <Route path="*" element={<Navigate to="/currencies" replace />} />
      </Routes>
    </HashRouter>
  );
}
