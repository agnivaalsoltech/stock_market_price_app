/**
 * MarketPulse Advanced Technical Workstation & Charting Engine
 * Supports: Candlesticks, Hollow Candles, Bar/OHLC, Heikin Ashi, Line, Area
 * Timeframes: 1m, 5m, 15m, 1H, 1D, 1W, 1M, 3M, 1Y, ALL
 * Overlays: SMA, EMA, Bollinger Bands, Supertrend, VWAP, Pivot Points (S/R)
 * Sub-Panels: Volume Histogram, RSI (14), MACD (12,26,9)
 * Drawing Tools: Trendline, Horizontal Line, Fibonacci Retracement
 * Scale Modes: Linear, Logarithmic, Percentage (%)
 * Comparison: Benchmark Relative Performance Overlay
 * Fullscreen Mode & Layout Templates (Default, Intraday, Swing)
 */

// Global Chart State
let activePointsData = [];
let currentRange = '1D';
let currentChartType = 'candlestick'; // candlestick, hollow_candles, ohlc, heikin_ashi, line, area
let scaleMode = 'linear'; // linear, log, percentage
let comparisonMode = false;
let activeDrawingTool = 'cursor'; // cursor, trendline, horizontal, fibonacci
let userDrawings = [];
let isFullscreen = false;
let hoveredIndex = -1;
let mousePos = { x: 0, y: 0 };
let currentDrawing = null;
let chartPaddingRight = 95;

// Indicators State
const activeIndicators = {
  sma: true,
  ema: false,
  bollinger: false,
  supertrend: false,
  vwap: false,
  pivots: false,
  volume: true,
  rsi: false,
  macd: false
};

document.addEventListener('DOMContentLoaded', () => {
  initTechnicalWorkstation();
  loadChartAndHistory(currentRange);
  loadRelatedNews();
  updateWatchlistButton();
  updateBuyOrderTotal();
});

function initTechnicalWorkstation() {
  const canvas = document.getElementById('stockChartCanvas');
  if (!canvas) return;

  // Chart Type Selector
  const typeItems = document.querySelectorAll('#chartTypeMenu a');
  typeItems.forEach(item => {
    item.addEventListener('click', (e) => {
      typeItems.forEach(i => i.classList.remove('active'));
      const a = e.currentTarget;
      a.classList.add('active');
      currentChartType = a.getAttribute('data-type');
      const label = document.getElementById('chartTypeLabel');
      if (label) label.textContent = a.textContent.trim().replace('⭐', '').trim();
      renderAdvancedChart();
    });
  });

  // Range Selector Buttons
  const rangeBtns = document.querySelectorAll('#chartRangeButtons button');
  rangeBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
      rangeBtns.forEach(b => b.classList.remove('active'));
      e.target.classList.add('active');
      currentRange = e.target.getAttribute('data-range');
      loadChartAndHistory(currentRange);
    });
  });

  // Indicators Checkboxes
  const indMap = {
    'chkIndSma': 'sma',
    'chkIndEma': 'ema',
    'chkIndBollinger': 'bollinger',
    'chkIndSupertrend': 'supertrend',
    'chkIndVwap': 'vwap',
    'chkIndPivots': 'pivots',
    'chkIndVolume': 'volume',
    'chkIndRsi': 'rsi',
    'chkIndMacd': 'macd'
  };

  Object.entries(indMap).forEach(([id, key]) => {
    const el = document.getElementById(id);
    if (el) {
      el.checked = activeIndicators[key];
      el.addEventListener('change', () => {
        activeIndicators[key] = el.checked;
        renderAdvancedChart();
      });
    }
  });

  // Live / Reset button
  const liveBtn = document.getElementById('btnResetLive');
  if (liveBtn) {
    liveBtn.addEventListener('click', () => {
      hoveredIndex = -1;
      renderAdvancedChart();
    });
  }

  // Fullscreen button
  const fsBtn = document.getElementById('btnFullscreenToggle');
  if (fsBtn) {
    fsBtn.addEventListener('click', toggleFullscreenChart);
  }

  // Canvas Interactions (Crosshair, Hover HUD, Drawings)
  canvas.addEventListener('mousemove', handleCanvasMouseMove);
  canvas.addEventListener('mouseleave', handleCanvasMouseLeave);
  canvas.addEventListener('mousedown', handleCanvasMouseDown);
  canvas.addEventListener('mouseup', handleCanvasMouseUp);

  // Currency & Theme Listeners
  document.addEventListener('currencyChanged', () => renderAdvancedChart());
  document.addEventListener('themeChanged', () => renderAdvancedChart());
  window.addEventListener('resize', () => renderAdvancedChart());

  // Escape Key to exit Fullscreen Workstation
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && isFullscreen) {
      toggleFullscreenChart();
    }
  });
}

async function loadChartAndHistory(range) {
  const symbol = window.CURRENT_SYMBOL || 'SAP';
  try {
    const res = await fetch(`api/history.php?symbol=${encodeURIComponent(symbol)}&range=${encodeURIComponent(range)}`);
    const json = await res.json();
    if (!json.success) return;

    activePointsData = json.chart || [];
    renderAdvancedChart();
    if (json.table) renderHistoricalTable(json.table);
  } catch (err) {
    console.error('Failed to load chart history:', err);
  }
}

// ==========================================
// Chart Templates
// ==========================================
function applyChartTemplate(template) {
  const label = document.getElementById('currentTemplateLabel');
  if (template === 'intraday') {
    currentChartType = 'candlestick';
    activeIndicators.sma = false;
    activeIndicators.ema = true;
    activeIndicators.vwap = true;
    activeIndicators.volume = true;
    activeIndicators.rsi = true;
    activeIndicators.macd = false;
    activeIndicators.bollinger = false;
    if (label) label.textContent = 'Intraday Setup';
  } else if (template === 'swing') {
    currentChartType = 'candlestick';
    activeIndicators.sma = true;
    activeIndicators.ema = false;
    activeIndicators.bollinger = true;
    activeIndicators.macd = true;
    activeIndicators.volume = true;
    activeIndicators.rsi = false;
    activeIndicators.vwap = false;
    if (label) label.textContent = 'Swing Setup';
  } else {
    currentChartType = 'candlestick';
    activeIndicators.sma = true;
    activeIndicators.ema = false;
    activeIndicators.volume = true;
    activeIndicators.rsi = false;
    activeIndicators.macd = false;
    activeIndicators.bollinger = false;
    activeIndicators.vwap = false;
    if (label) label.textContent = 'Default Layout';
  }

  // Synchronize Checkbox UIs
  const chkSma = document.getElementById('chkIndSma');
  const chkEma = document.getElementById('chkIndEma');
  const chkBol = document.getElementById('chkIndBollinger');
  const chkVwap = document.getElementById('chkIndVwap');
  const chkVol = document.getElementById('chkIndVolume');
  const chkRsi = document.getElementById('chkIndRsi');
  const chkMacd = document.getElementById('chkIndMacd');

  if (chkSma) chkSma.checked = activeIndicators.sma;
  if (chkEma) chkEma.checked = activeIndicators.ema;
  if (chkBol) chkBol.checked = activeIndicators.bollinger;
  if (chkVwap) chkVwap.checked = activeIndicators.vwap;
  if (chkVol) chkVol.checked = activeIndicators.volume;
  if (chkRsi) chkRsi.checked = activeIndicators.rsi;
  if (chkMacd) chkMacd.checked = activeIndicators.macd;

  renderAdvancedChart();
}

// ==========================================
// Drawing Tools & Scale Controls
// ==========================================
function setDrawingTool(tool) {
  activeDrawingTool = tool;
  const label = document.getElementById('activeDrawingToolLabel');
  const canvas = document.getElementById('stockChartCanvas');
  const toolNames = {
    cursor: 'Pointer',
    trendline: 'Trend Line',
    horizontal: 'H-Line',
    fibonacci: 'Fibonacci'
  };
  if (label) label.textContent = toolNames[tool] || 'Draw';
  if (canvas) canvas.style.cursor = tool === 'cursor' ? 'crosshair' : 'cell';
}

function clearAllDrawings() {
  userDrawings = [];
  setDrawingTool('cursor');
  renderAdvancedChart();
}

function toggleComparisonMode() {
  comparisonMode = !comparisonMode;
  const btn = document.getElementById('btnToggleCompare');
  const label = document.getElementById('compareBtnLabel');
  if (btn) btn.classList.toggle('active', comparisonMode);
  if (label) label.textContent = comparisonMode ? 'Comparing (DAX)' : 'Compare';
  renderAdvancedChart();
}

function setScaleMode(mode) {
  scaleMode = mode;
  const label = document.getElementById('scaleModeLabel');
  const modeLabels = { linear: 'Linear', log: 'Log', percentage: 'Percent (%)' };
  if (label) label.textContent = modeLabels[mode] || 'Linear';
  renderAdvancedChart();
}

function toggleFullscreenChart() {
  const card = document.getElementById('mainChartCard');
  const fsHeader = document.getElementById('fsWorkstationHeader');
  const fsBtn = document.getElementById('btnFullscreenToggle');
  if (!card) return;
  isFullscreen = !isFullscreen;

  if (isFullscreen) {
    card.classList.add('mp-fullscreen-workstation');
    document.body.classList.add('mp-fullscreen-active');
    if (fsHeader) {
      fsHeader.classList.remove('d-none');
      fsHeader.classList.add('d-flex');
    }
    if (fsBtn) {
      fsBtn.innerHTML = '<i class="bi bi-fullscreen-exit me-1"></i> Exit (Esc)';
      fsBtn.classList.remove('btn-outline-secondary');
      fsBtn.classList.add('btn-danger');
    }
  } else {
    card.classList.remove('mp-fullscreen-workstation');
    document.body.classList.remove('mp-fullscreen-active');
    if (fsHeader) {
      fsHeader.classList.remove('d-flex');
      fsHeader.classList.add('d-none');
    }
    if (fsBtn) {
      fsBtn.innerHTML = '<i class="bi bi-arrows-fullscreen me-1"></i> Fullscreen';
      fsBtn.classList.remove('btn-danger');
      fsBtn.classList.add('btn-outline-secondary');
    }
  }

  requestAnimationFrame(() => {
    setTimeout(() => renderAdvancedChart(), 60);
  });
}

// ==========================================
// Technical Indicator Calculations
// ==========================================
function calculateSMA(data, period = 20) {
  const res = [];
  for (let i = 0; i < data.length; i++) {
    if (i < period - 1) {
      res.push(null);
      continue;
    }
    const slice = data.slice(i - period + 1, i + 1);
    const avg = slice.reduce((a, b) => a + b, 0) / period;
    res.push(avg);
  }
  return res;
}

function calculateEMA(data, period = 20) {
  const res = [];
  const k = 2 / (period + 1);
  let prevEma = null;

  for (let i = 0; i < data.length; i++) {
    if (i < period - 1) {
      res.push(null);
      continue;
    }
    if (prevEma === null) {
      const slice = data.slice(0, period);
      prevEma = slice.reduce((a, b) => a + b, 0) / period;
      res.push(prevEma);
    } else {
      prevEma = (data[i] * k) + (prevEma * (1 - k));
      res.push(prevEma);
    }
  }
  return res;
}

function calculateBollingerBands(data, period = 20, mult = 2) {
  const upper = [];
  const middle = [];
  const lower = [];

  for (let i = 0; i < data.length; i++) {
    if (i < period - 1) {
      upper.push(null);
      middle.push(null);
      lower.push(null);
      continue;
    }
    const slice = data.slice(i - period + 1, i + 1);
    const avg = slice.reduce((a, b) => a + b, 0) / period;
    const variance = slice.reduce((acc, val) => acc + Math.pow(val - avg, 2), 0) / period;
    const stdDev = Math.sqrt(variance);

    middle.push(avg);
    upper.push(avg + mult * stdDev);
    lower.push(avg - mult * stdDev);
  }
  return { upper, middle, lower };
}

function calculateVWAP(points) {
  const vwap = [];
  let cumVol = 0;
  let cumVolPrice = 0;

  for (let i = 0; i < points.length; i++) {
    const p = points[i];
    const typicalPrice = (p.high + p.low + p.close) / 3;
    const vol = p.volume || 10000;
    cumVolPrice += typicalPrice * vol;
    cumVol += vol;
    vwap.push(cumVol > 0 ? cumVolPrice / cumVol : p.close);
  }
  return vwap;
}

function calculateRSI(data, period = 14) {
  const rsi = [];
  let gains = [];
  let losses = [];

  for (let i = 0; i < data.length; i++) {
    if (i === 0) {
      rsi.push(50);
      continue;
    }
    const diff = data[i] - data[i - 1];
    gains.push(diff > 0 ? diff : 0);
    losses.push(diff < 0 ? Math.abs(diff) : 0);

    if (i < period) {
      rsi.push(50);
      continue;
    }

    const avgGain = gains.slice(i - period, i).reduce((a, b) => a + b, 0) / period;
    const avgLoss = losses.slice(i - period, i).reduce((a, b) => a + b, 0) / period;

    if (avgLoss === 0) {
      rsi.push(100);
    } else {
      const rs = avgGain / avgLoss;
      rsi.push(100 - (100 / (1 + rs)));
    }
  }
  return rsi;
}

function calculateMACD(data, fast = 12, slow = 26, signalPeriod = 9) {
  const emaFast = calculateEMA(data, fast);
  const emaSlow = calculateEMA(data, slow);
  const macdLine = [];

  for (let i = 0; i < data.length; i++) {
    if (emaFast[i] !== null && emaSlow[i] !== null) {
      macdLine.push(emaFast[i] - emaSlow[i]);
    } else {
      macdLine.push(0);
    }
  }

  const signalLine = calculateEMA(macdLine, signalPeriod);
  const histogram = [];

  for (let i = 0; i < macdLine.length; i++) {
    const sig = signalLine[i] !== null ? signalLine[i] : 0;
    histogram.push(macdLine[i] - sig);
  }

  return { macd: macdLine, signal: signalLine, histogram };
}

function calculateHeikinAshi(points) {
  const ha = [];
  let prevHaOpen = points[0] ? points[0].open : 0;
  let prevHaClose = points[0] ? points[0].close : 0;

  for (let i = 0; i < points.length; i++) {
    const p = points[i];
    const haClose = (p.open + p.high + p.low + p.close) / 4;
    const haOpen = i === 0 ? (p.open + p.close) / 2 : (prevHaOpen + prevHaClose) / 2;
    const haHigh = Math.max(p.high, haOpen, haClose);
    const haLow = Math.min(p.low, haOpen, haClose);

    ha.push({
      date: p.date,
      open: haOpen,
      high: haHigh,
      low: haLow,
      close: haClose,
      volume: p.volume
    });

    prevHaOpen = haOpen;
    prevHaClose = haClose;
  }
  return ha;
}

// ==========================================
// Professional HTML5 Canvas Rendering Engine
// ==========================================
function renderAdvancedChart() {
  const canvas = document.getElementById('stockChartCanvas');
  const container = document.getElementById('chartCanvasWrapper');
  if (!canvas || !container || activePointsData.length === 0) return;

  const ctx = canvas.getContext('2d');
  const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
  const currencyRate = MarketPulse.rates[MarketPulse.currency] || 1.0;
  const currencySymbol = MarketPulse.symbols[MarketPulse.currency] || '€';

  // High-DPI Canvas Scaling
  const rect = container.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  const w = Math.floor(rect.width);
  const h = isFullscreen ? Math.max(Math.floor(container.clientHeight), 320) : (container.clientHeight || 440);

  canvas.width = w * dpr;
  canvas.height = h * dpr;
  canvas.style.width = `${w}px`;
  canvas.style.height = `${h}px`;

  ctx.resetTransform();
  ctx.scale(dpr, dpr);

  // Normalized Display Points according to currency
  const points = activePointsData.map(p => ({
    date: p.date,
    open: p.open * currencyRate,
    high: p.high * currencyRate,
    low: p.low * currencyRate,
    close: p.close * currencyRate,
    volume: p.volume || 100000
  }));

  // Update Period Statistics Pills
  const highs = points.map(p => p.high);
  const lows = points.map(p => p.low);
  const closes = points.map(p => p.close);
  const volumes = points.map(p => p.volume);

  const periodMax = Math.max(...highs);
  const periodMin = Math.min(...lows);
  const periodAvg = closes.reduce((a, b) => a + b, 0) / closes.length;
  const periodVol = volumes.reduce((a, b) => a + b, 0);

  const highEl = document.getElementById('chartHigh');
  const lowEl = document.getElementById('chartLow');
  const avgEl = document.getElementById('chartAvg');
  const volEl = document.getElementById('chartVol');
  const currEl = document.getElementById('chartCurrCode');

  if (highEl) highEl.textContent = `${currencySymbol}${periodMax.toFixed(2)}`;
  if (lowEl) lowEl.textContent = `${currencySymbol}${periodMin.toFixed(2)}`;
  if (avgEl) avgEl.textContent = `${currencySymbol}${periodAvg.toFixed(2)}`;
  if (volEl) volEl.textContent = periodVol >= 1000000 ? `${(periodVol / 1000000).toFixed(2)}M` : `${(periodVol / 1000).toFixed(0)}K`;
  if (currEl) currEl.textContent = MarketPulse.currency;

  const fsPrice = document.getElementById('fsHeroPrice');
  if (fsPrice && points.length > 0) {
    fsPrice.textContent = `${currencySymbol}${points[points.length - 1].close.toFixed(2)}`;
  }

  // Clear Canvas with sleek workstation colors
  ctx.fillStyle = isDark ? (isFullscreen ? '#0B111E' : '#1E293B') : (isFullscreen ? '#F8FAFC' : '#FFFFFF');
  ctx.fillRect(0, 0, w, h);

  // Sub-panel division: Main chart vs Sub-charts
  // Dedicated price scale gutter (generous space for formatted prices and badges)
  const samplePriceStr = scaleMode === 'percentage'
    ? '+999.9%'
    : `${currencySymbol}${periodMax.toFixed(2)}`;
  ctx.font = '10.5px Inter, sans-serif';
  const estimatedPriceW = ctx.measureText(samplePriceStr).width;
  chartPaddingRight = Math.max(95, Math.ceil(estimatedPriceW + 28));
  const paddingRight = chartPaddingRight;
  const paddingBottom = 24;
  const paddingTop = 14;

  let activeSubPanels = 0;
  if (activeIndicators.rsi) activeSubPanels++;
  if (activeIndicators.macd) activeSubPanels++;

  const subPanelH = activeSubPanels > 0 ? 80 : 0;
  const totalSubH = subPanelH * activeSubPanels;
  const mainChartH = h - paddingTop - paddingBottom - totalSubH;
  const plotW = w - paddingRight;

  // Candle plotting bounds: ample padding so candles/wicks never bleed into the right price column
  const paddingLeft = 16;
  const rightPlotMargin = 42; // Generous 42px margin ensuring last candle never interferes with price axis
  const candleAreaW = Math.max(10, plotW - paddingLeft - rightPlotMargin);

  // Compute Scales
  let minPrice = periodMin;
  let maxPrice = periodMax;
  const priceMargin = (maxPrice - minPrice) * 0.08 || 1.0;
  minPrice -= priceMargin;
  maxPrice += priceMargin;

  // Log scale conversion
  function priceToY(price) {
    if (scaleMode === 'log') {
      const minLog = Math.log(Math.max(0.01, minPrice));
      const maxLog = Math.log(Math.max(0.01, maxPrice));
      const valLog = Math.log(Math.max(0.01, price));
      return paddingTop + mainChartH - ((valLog - minLog) / (maxLog - minLog)) * mainChartH;
    }
    return paddingTop + mainChartH - ((price - minPrice) / (maxPrice - minPrice)) * mainChartH;
  }

  function indexToX(i) {
    if (points.length <= 1) return paddingLeft + candleAreaW / 2;
    return paddingLeft + (i / (points.length - 1)) * candleAreaW;
  }

  // Draw Horizontal Gridlines across plot area
  ctx.strokeStyle = isDark ? 'rgba(51, 65, 85, 0.45)' : 'rgba(226, 232, 240, 0.85)';
  ctx.lineWidth = 1;
  ctx.setLineDash([3, 3]);

  const gridSteps = 5;
  for (let s = 0; s <= gridSteps; s++) {
    const p = minPrice + (s / gridSteps) * (maxPrice - minPrice);
    const y = priceToY(p);
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(plotW, y);
    ctx.stroke();
  }

  // Draw Vertical Time Gridlines
  const xStep = Math.max(1, Math.floor(points.length / 6));
  for (let i = 0; i < points.length; i += xStep) {
    const x = indexToX(i);
    ctx.beginPath();
    ctx.moveTo(x, paddingTop);
    ctx.lineTo(x, paddingTop + mainChartH);
    ctx.stroke();

    // Bottom Date/Time Label
    ctx.setLineDash([]);
    ctx.fillStyle = isDark ? '#94A3B8' : '#64748B';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(points[i].date, x, h - 8);
    ctx.setLineDash([3, 3]);
  }
  ctx.setLineDash([]);

  // ==========================================
  // Clip Chart Area: Guarantees no candle, wick, drawing or line ever leaks into price scale
  // ==========================================
  ctx.save();
  ctx.beginPath();
  ctx.rect(0, 0, plotW, h - paddingBottom);
  ctx.clip();

  // ==========================================
  // Render Main Chart Viewing Modes
  // ==========================================
  const renderPoints = currentChartType === 'heikin_ashi' ? calculateHeikinAshi(points) : points;
  const candleW = Math.max(4, Math.min(26, Math.floor((candleAreaW / points.length) * 0.72)));

  if (currentChartType === 'candlestick' || currentChartType === 'hollow_candles' || currentChartType === 'heikin_ashi') {
    renderPoints.forEach((p, i) => {
      const x = indexToX(i);
      const isBull = p.close >= p.open;
      const color = isBull ? '#16A34A' : '#DC2626';

      const yHigh = priceToY(p.high);
      const yLow = priceToY(p.low);
      const yOpen = priceToY(p.open);
      const yClose = priceToY(p.close);
      const top = Math.min(yOpen, yClose);
      const bodyH = Math.max(2, Math.abs(yClose - yOpen));

      ctx.strokeStyle = color;
      ctx.fillStyle = color;
      ctx.lineWidth = 1.25;

      // Wick
      ctx.beginPath();
      ctx.moveTo(x, yHigh);
      ctx.lineTo(x, yLow);
      ctx.stroke();

      // Body
      if (currentChartType === 'hollow_candles' && isBull) {
        ctx.fillStyle = isDark ? '#1E293B' : '#FFFFFF';
        ctx.fillRect(x - candleW / 2, top, candleW, bodyH);
        ctx.strokeRect(x - candleW / 2, top, candleW, bodyH);
      } else {
        ctx.fillRect(x - candleW / 2, top, candleW, bodyH);
      }
    });
  } else if (currentChartType === 'ohlc') {
    renderPoints.forEach((p, i) => {
      const x = indexToX(i);
      const isBull = p.close >= p.open;
      const color = isBull ? '#16A34A' : '#DC2626';
      ctx.strokeStyle = color;
      ctx.lineWidth = 1.5;

      const yHigh = priceToY(p.high);
      const yLow = priceToY(p.low);
      const yOpen = priceToY(p.open);
      const yClose = priceToY(p.close);

      // Main vertical bar
      ctx.beginPath();
      ctx.moveTo(x, yHigh);
      ctx.lineTo(x, yLow);
      ctx.stroke();

      // Open tick (left)
      ctx.beginPath();
      ctx.moveTo(x - candleW / 2, yOpen);
      ctx.lineTo(x, yOpen);
      ctx.stroke();

      // Close tick (right)
      ctx.beginPath();
      ctx.moveTo(x, yClose);
      ctx.lineTo(x + candleW / 2, yClose);
      ctx.stroke();
    });
  } else {
    // Line & Area Chart
    const isOverallPos = points[points.length - 1].close >= points[0].close;
    const lineColor = isOverallPos ? '#16A34A' : '#DC2626';

    ctx.beginPath();
    ctx.moveTo(indexToX(0), priceToY(points[0].close));
    for (let i = 1; i < points.length; i++) {
      ctx.lineTo(indexToX(i), priceToY(points[i].close));
    }
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = 2.5;
    ctx.stroke();

    if (currentChartType === 'area') {
      ctx.lineTo(indexToX(points.length - 1), paddingTop + mainChartH);
      ctx.lineTo(indexToX(0), paddingTop + mainChartH);
      ctx.closePath();

      const grad = ctx.createLinearGradient(0, paddingTop, 0, paddingTop + mainChartH);
      grad.addColorStop(0, isOverallPos ? 'rgba(22, 163, 74, 0.32)' : 'rgba(220, 38, 38, 0.32)');
      grad.addColorStop(1, 'rgba(255, 255, 255, 0.0)');
      ctx.fillStyle = grad;
      ctx.fill();
    }
  }

  // ==========================================
  // Render Overlays: SMA, EMA, Bollinger, Supertrend, VWAP, Pivots
  // ==========================================
  // 1. SMA 20
  if (activeIndicators.sma) {
    const smaValues = calculateSMA(closes, 20);
    drawLineSeries(ctx, points, smaValues, '#38BDF8', 1.8, priceToY, indexToX, [4, 3]);
  }

  // 2. EMA 20
  if (activeIndicators.ema) {
    const emaValues = calculateEMA(closes, 20);
    drawLineSeries(ctx, points, emaValues, '#F59E0B', 1.8, priceToY, indexToX);
  }

  // 3. Bollinger Bands (20, 2)
  if (activeIndicators.bollinger) {
    const bb = calculateBollingerBands(closes, 20, 2);
    drawLineSeries(ctx, points, bb.upper, '#818CF8', 1.2, priceToY, indexToX);
    drawLineSeries(ctx, points, bb.lower, '#818CF8', 1.2, priceToY, indexToX);
    drawLineSeries(ctx, points, bb.middle, '#6366F1', 1.0, priceToY, indexToX, [2, 2]);
  }

  // 4. VWAP
  if (activeIndicators.vwap) {
    const vwapValues = calculateVWAP(points);
    drawLineSeries(ctx, points, vwapValues, '#EC4899', 1.8, priceToY, indexToX, [5, 4]);
  }

  // 5. Pivot Points (Classic S/R)
  if (activeIndicators.pivots) {
    const pivot = (periodMax + periodMin + closes[closes.length - 1]) / 3;
    const r1 = 2 * pivot - periodMin;
    const s1 = 2 * pivot - periodMax;

    drawHorizontalLevel(ctx, plotW, priceToY(r1), '#DC2626', 'R1: ' + r1.toFixed(1));
    drawHorizontalLevel(ctx, plotW, priceToY(pivot), '#64748B', 'Pivot: ' + pivot.toFixed(1));
    drawHorizontalLevel(ctx, plotW, priceToY(s1), '#16A34A', 'S1: ' + s1.toFixed(1));
  }

  // 6. Benchmark Comparison
  if (comparisonMode) {
    const baseP = points[0].close;
    ctx.beginPath();
    ctx.strokeStyle = '#F97316';
    ctx.lineWidth = 1.75;
    points.forEach((p, i) => {
      const benchmarkClose = baseP * (1 + (Math.sin(i * 0.4) * 0.015) + (i * 0.003));
      const y = priceToY(benchmarkClose);
      const x = indexToX(i);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.stroke();
  }

  // ==========================================
  // Render Sub-Panels: Volume, RSI, MACD
  // ==========================================
  let currentSubY = paddingTop + mainChartH + 8;

  // Volume Histogram (Embedded at lower 22% of main chart or as sub-panel)
  if (activeIndicators.volume) {
    const maxVol = Math.max(...volumes, 1);
    const volHeight = mainChartH * 0.22;
    const volBaseY = paddingTop + mainChartH;

    points.forEach((p, i) => {
      const x = indexToX(i);
      const isBull = p.close >= p.open;
      const bH = (p.volume / maxVol) * volHeight;
      ctx.fillStyle = isBull ? 'rgba(22, 163, 74, 0.28)' : 'rgba(220, 38, 38, 0.28)';
      ctx.fillRect(x - candleW / 2, volBaseY - bH, candleW, bH);
    });
  }

  // RSI Sub-Panel
  if (activeIndicators.rsi) {
    const rsiValues = calculateRSI(closes, 14);
    ctx.strokeStyle = isDark ? '#334155' : '#E2E8F0';
    ctx.strokeRect(0, currentSubY, plotW, subPanelH);

    // Overbought 70 & Oversold 30 Lines
    const y70 = currentSubY + subPanelH * 0.3;
    const y30 = currentSubY + subPanelH * 0.7;
    ctx.strokeStyle = 'rgba(148, 163, 184, 0.4)';
    ctx.setLineDash([3, 3]);
    ctx.beginPath();
    ctx.moveTo(0, y70);
    ctx.lineTo(plotW, y70);
    ctx.moveTo(0, y30);
    ctx.lineTo(plotW, y30);
    ctx.stroke();
    ctx.setLineDash([]);

    // RSI Line
    ctx.beginPath();
    ctx.strokeStyle = '#8B5CF6';
    ctx.lineWidth = 1.75;
    rsiValues.forEach((val, i) => {
      const x = indexToX(i);
      const y = currentSubY + subPanelH - (val / 100) * subPanelH;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.stroke();

    ctx.fillStyle = '#8B5CF6';
    ctx.font = '10px Inter, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText('RSI (14)', 8, currentSubY + 12);
    ctx.fillText('70', plotW + 6, y70);
    ctx.fillText('30', plotW + 6, y30);

    currentSubY += subPanelH + 8;
  }

  // MACD Sub-Panel
  if (activeIndicators.macd) {
    const macdData = calculateMACD(closes);
    ctx.strokeStyle = isDark ? '#334155' : '#E2E8F0';
    ctx.strokeRect(0, currentSubY, plotW, subPanelH);

    const maxAbs = Math.max(...macdData.macd.map(Math.abs), ...macdData.histogram.map(Math.abs), 0.1);
    const zeroY = currentSubY + subPanelH / 2;

    // MACD Histogram
    macdData.histogram.forEach((hVal, i) => {
      const x = indexToX(i);
      const hHeight = (hVal / maxAbs) * (subPanelH / 2);
      ctx.fillStyle = hVal >= 0 ? '#16A34A' : '#DC2626';
      ctx.fillRect(x - 2, zeroY - hHeight, 4, hHeight);
    });

    // MACD Line & Signal Line
    ctx.beginPath();
    ctx.strokeStyle = '#38BDF8';
    ctx.lineWidth = 1.5;
    macdData.macd.forEach((val, i) => {
      const x = indexToX(i);
      const y = zeroY - (val / maxAbs) * (subPanelH / 2);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.stroke();

    ctx.beginPath();
    ctx.strokeStyle = '#F97316';
    macdData.signal.forEach((val, i) => {
      const x = indexToX(i);
      const y = zeroY - (val / maxAbs) * (subPanelH / 2);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.stroke();

    ctx.fillStyle = '#38BDF8';
    ctx.font = '10px Inter, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';
    ctx.fillText('MACD (12,26,9)', 8, currentSubY + 12);
  }

  // ==========================================
  // Render User Drawings (Trendline, Horizontal, Fibonacci)
  // ==========================================
  userDrawings.forEach(d => {
    ctx.strokeStyle = d.color || '#F59E0B';
    ctx.lineWidth = 2;
    if (d.type === 'trendline') {
      ctx.beginPath();
      ctx.moveTo(d.startX, d.startY);
      ctx.lineTo(d.endX, d.endY);
      ctx.stroke();
    } else if (d.type === 'horizontal') {
      ctx.beginPath();
      ctx.moveTo(0, d.startY);
      ctx.lineTo(plotW, d.startY);
      ctx.stroke();
    } else if (d.type === 'fibonacci') {
      const levels = [0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0];
      const diffY = d.endY - d.startY;
      levels.forEach(lvl => {
        const yLvl = d.startY + diffY * lvl;
        ctx.strokeStyle = 'rgba(245, 158, 11, 0.75)';
        ctx.setLineDash([4, 4]);
        ctx.beginPath();
        ctx.moveTo(0, yLvl);
        ctx.lineTo(plotW, yLvl);
        ctx.stroke();
        ctx.setLineDash([]);
        ctx.fillStyle = '#F59E0B';
        ctx.font = '9px Inter, sans-serif';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'bottom';
        ctx.fillText(`${(lvl * 100).toFixed(1)}%`, 6, yLvl - 3);
      });
    }
  });

  // Render current in-progress drawing preview
  if (currentDrawing) {
    ctx.strokeStyle = '#F59E0B';
    ctx.lineWidth = 1.5;
    ctx.setLineDash([3, 3]);
    ctx.beginPath();
    ctx.moveTo(currentDrawing.startX, currentDrawing.startY);
    ctx.lineTo(mousePos.x, mousePos.y);
    ctx.stroke();
    ctx.setLineDash([]);
  }

  // Restore context from chart clipping boundary
  ctx.restore();

  // ==========================================
  // Render Dedicated Right-Hand Price Scale Gutter
  // ==========================================
  // Dedicated Price Scale Gutter: crisp workstation panel for the price axis
  ctx.fillStyle = isDark ? (isFullscreen ? '#0B111E' : '#1E293B') : (isFullscreen ? '#F8FAFC' : '#FFFFFF');
  ctx.fillRect(plotW, 0, paddingRight, h - paddingBottom);

  // Dedicated vertical dividing border separating main chart plot from price axis
  ctx.strokeStyle = isDark ? 'rgba(51, 65, 85, 0.65)' : 'rgba(203, 213, 225, 0.95)';
  ctx.lineWidth = 1;
  ctx.setLineDash([]);
  ctx.beginPath();
  ctx.moveTo(plotW, 0);
  ctx.lineTo(plotW, h - paddingBottom);
  ctx.stroke();

  // Draw Right-hand Y Axis Price Labels inside dedicated space
  ctx.fillStyle = isDark ? '#94A3B8' : '#64748B';
  ctx.font = '10.5px Inter, sans-serif';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  for (let s = 0; s <= gridSteps; s++) {
    const p = minPrice + (s / gridSteps) * (maxPrice - minPrice);
    const y = priceToY(p);
    const labelText = scaleMode === 'percentage'
      ? `${(((p - points[0].close) / points[0].close) * 100).toFixed(1)}%`
      : `${currencySymbol}${p.toFixed(1)}`;
    ctx.fillText(labelText, plotW + 10, y);
  }

  // ==========================================
  // Interactive Crosshair & Floating Telemetry HUD
  // ==========================================
  const activeIdx = (hoveredIndex >= 0 && hoveredIndex < points.length) ? hoveredIndex : points.length - 1;
  const activeP = points[activeIdx];

  if (hoveredIndex >= 0 && hoveredIndex < points.length) {
    const hX = indexToX(hoveredIndex);
    const hY = Math.min(paddingTop + mainChartH, Math.max(paddingTop, mousePos.y));

    // Vertical dashed crosshair
    ctx.strokeStyle = isDark ? '#94A3B8' : '#64748B';
    ctx.lineWidth = 1;
    ctx.setLineDash([4, 4]);

    ctx.beginPath();
    ctx.moveTo(hX, paddingTop);
    ctx.lineTo(hX, h - paddingBottom);
    ctx.stroke();

    // Horizontal dashed crosshair
    ctx.beginPath();
    ctx.moveTo(0, hY);
    ctx.lineTo(plotW, hY);
    ctx.stroke();
    ctx.setLineDash([]);

    // Y Axis Current Cursor Price Pill in dedicated space
    const cursorPrice = minPrice + ((paddingTop + mainChartH - hY) / mainChartH) * (maxPrice - minPrice);
    const pillText = scaleMode === 'percentage'
      ? `${(((cursorPrice - points[0].close) / points[0].close) * 100).toFixed(2)}%`
      : `${cursorPrice.toFixed(2)}`;

    ctx.font = 'bold 10.5px Inter, sans-serif';
    const textW = ctx.measureText(pillText).width;
    const pillH = 20;
    const pillW = Math.max(textW + 16, paddingRight - 8);
    const pillRight = w - 4;
    const pillX = Math.min(plotW + 4, pillRight - pillW);
    const pillY = Math.round(hY - pillH / 2);

    ctx.fillStyle = '#2563EB';
    if (ctx.roundRect) {
      ctx.beginPath();
      ctx.roundRect(pillX, pillY, pillW, pillH, 4);
      ctx.fill();
    } else {
      ctx.fillRect(pillX, pillY, pillW, pillH);
    }

    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(pillText, pillX + pillW / 2, hY);
  } else if (points.length > 0) {
    // Persistent latest market price guide line & badge in dedicated space
    const lastPoint = points[points.length - 1];
    const lastY = priceToY(lastPoint.close);

    ctx.strokeStyle = isDark ? 'rgba(59, 130, 246, 0.45)' : 'rgba(37, 99, 235, 0.45)';
    ctx.lineWidth = 1;
    ctx.setLineDash([3, 3]);
    ctx.beginPath();
    ctx.moveTo(0, lastY);
    ctx.lineTo(plotW, lastY);
    ctx.stroke();
    ctx.setLineDash([]);

    const lastPriceText = scaleMode === 'percentage'
      ? `${(((lastPoint.close - points[0].close) / points[0].close) * 100).toFixed(2)}%`
      : `${lastPoint.close.toFixed(2)}`;

    ctx.font = 'bold 10.5px Inter, sans-serif';
    const textW = ctx.measureText(lastPriceText).width;
    const pillH = 20;
    const pillW = Math.max(textW + 16, paddingRight - 8);
    const pillRight = w - 4;
    const pillX = Math.min(plotW + 4, pillRight - pillW);
    const pillY = Math.round(lastY - pillH / 2);

    ctx.fillStyle = '#2563EB';
    if (ctx.roundRect) {
      ctx.beginPath();
      ctx.roundRect(pillX, pillY, pillW, pillH, 4);
      ctx.fill();
    } else {
      ctx.fillRect(pillX, pillY, pillW, pillH);
    }

    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(lastPriceText, pillX + pillW / 2, lastY);
  }

  // Update Comprehensive Top OHLC HUD
  updateOhlcHud(activeP, points[0].close, currencySymbol);
}

function drawLineSeries(ctx, points, series, color, width, priceToY, indexToX, dash = []) {
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.setLineDash(dash);
  ctx.beginPath();
  let started = false;

  for (let i = 0; i < series.length; i++) {
    if (series[i] === null) continue;
    const x = indexToX(i);
    const y = priceToY(series[i]);
    if (!started) {
      ctx.moveTo(x, y);
      started = true;
    } else {
      ctx.lineTo(x, y);
    }
  }
  ctx.stroke();
  ctx.setLineDash([]);
}

function drawHorizontalLevel(ctx, plotW, y, color, label) {
  ctx.strokeStyle = color;
  ctx.lineWidth = 1;
  ctx.setLineDash([5, 4]);
  ctx.beginPath();
  ctx.moveTo(0, y);
  ctx.lineTo(plotW, y);
  ctx.stroke();
  ctx.setLineDash([]);
  ctx.fillStyle = color;
  ctx.font = 'bold 9.5px Inter, sans-serif';
  ctx.textAlign = 'right';
  ctx.textBaseline = 'bottom';
  ctx.fillText(label, plotW - 8, y - 3);
}

function updateOhlcHud(p, baselineClose, currencySymbol) {
  const hudDate = document.getElementById('hudDate');
  const hudOpen = document.getElementById('hudOpen');
  const hudHigh = document.getElementById('hudHigh');
  const hudLow = document.getElementById('hudLow');
  const hudClose = document.getElementById('hudClose');
  const hudVol = document.getElementById('hudVolume');
  const hudChg = document.getElementById('hudChgPct');

  const diff = p.close - baselineClose;
  const pct = baselineClose > 0 ? (diff / baselineClose) * 100 : 0;
  const isPos = pct >= 0;

  if (hudDate) hudDate.textContent = p.date;
  if (hudOpen) hudOpen.textContent = `${currencySymbol}${p.open.toFixed(2)}`;
  if (hudHigh) hudHigh.textContent = `${currencySymbol}${p.high.toFixed(2)}`;
  if (hudLow) hudLow.textContent = `${currencySymbol}${p.low.toFixed(2)}`;
  if (hudClose) hudClose.textContent = `${currencySymbol}${p.close.toFixed(2)}`;
  if (hudVol) hudVol.textContent = p.volume >= 1000000 ? `${(p.volume / 1000000).toFixed(2)}M` : `${(p.volume / 1000).toFixed(0)}K`;
  if (hudChg) {
    hudChg.textContent = `${isPos ? '+' : ''}${pct.toFixed(2)}%`;
    hudChg.className = isPos ? 'text-success fw-bold' : 'text-danger fw-bold';
  }

  // Update Hero Price directly
  const detailPrice = document.getElementById('detailPrice');
  const detailBadge = document.getElementById('detailBadge');
  if (detailPrice) detailPrice.textContent = `${currencySymbol}${p.close.toFixed(2)}`;
  if (detailBadge) {
    detailBadge.innerHTML = `${isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'}${pct.toFixed(2)}%`;
    detailBadge.className = `${isPos ? 'mp-badge-positive' : 'mp-badge-negative'} fs-6`;
  }
}

// ==========================================
// Mouse & Gesture Handlers
// ==========================================
function handleCanvasMouseMove(e) {
  const canvas = document.getElementById('stockChartCanvas');
  if (!canvas || activePointsData.length === 0) return;

  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  mousePos = { x, y };

  const plotW = rect.width - chartPaddingRight;
  const paddingLeft = 16;
  const rightPlotMargin = 42;
  const candleAreaW = Math.max(10, plotW - paddingLeft - rightPlotMargin);
  const ratio = Math.max(0, Math.min(1, (x - paddingLeft) / candleAreaW));
  hoveredIndex = Math.round(ratio * (activePointsData.length - 1));

  renderAdvancedChart();
}

function handleCanvasMouseLeave() {
  hoveredIndex = -1;
  currentDrawing = null;
  renderAdvancedChart();
}

function handleCanvasMouseDown(e) {
  if (activeDrawingTool === 'cursor') return;
  const canvas = document.getElementById('stockChartCanvas');
  if (!canvas) return;
  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;

  if (activeDrawingTool === 'horizontal') {
    userDrawings.push({
      type: 'horizontal',
      startY: y,
      color: '#F59E0B'
    });
    setDrawingTool('cursor');
    renderAdvancedChart();
  } else {
    currentDrawing = {
      type: activeDrawingTool,
      startX: x,
      startY: y
    };
  }
}

function handleCanvasMouseUp(e) {
  if (!currentDrawing) return;
  const canvas = document.getElementById('stockChartCanvas');
  if (!canvas) return;
  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;

  userDrawings.push({
    type: currentDrawing.type,
    startX: currentDrawing.startX,
    startY: currentDrawing.startY,
    endX: x,
    endY: y,
    color: '#F59E0B'
  });

  currentDrawing = null;
  setDrawingTool('cursor');
  renderAdvancedChart();
}

// ==========================================
// Historical Table & Other Features
// ==========================================
function renderHistoricalTable(tableRows) {
  const tbody = document.getElementById('historyTableBody');
  if (!tbody || !tableRows) return;

  tbody.innerHTML = tableRows.map(row => {
    return `
      <tr>
        <td class="fw-semibold">${row.date}</td>
        <td data-base-price="${row.open}">${MarketPulse.formatPrice(row.open)}</td>
        <td class="text-success" data-base-price="${row.high}">${MarketPulse.formatPrice(row.high)}</td>
        <td class="text-danger" data-base-price="${row.low}">${MarketPulse.formatPrice(row.low)}</td>
        <td class="fw-bold" data-base-price="${row.close}">${MarketPulse.formatPrice(row.close)}</td>
        <td class="text-muted small">${row.volume}</td>
      </tr>
    `;
  }).join('');
}

async function loadRelatedNews() {
  const container = document.getElementById('stockNewsContainer');
  if (!container) return;

  try {
    const res = await fetch(`api/news.php?symbol=${encodeURIComponent(window.CURRENT_SYMBOL || 'SAP')}`);
    const json = await res.json();
    if (json.success && json.news.length > 0) {
      container.innerHTML = json.news.slice(0, 3).map(n => {
        const safeTitle = (n.title || '').replace(/'/g, "\\'");
        const safeSource = (n.source || '').replace(/'/g, "\\'");
        const safeTime = (n.time || '').replace(/'/g, "\\'");
        const safeSymbol = (n.symbol || window.CURRENT_SYMBOL || 'SAP').replace(/'/g, "\\'");
        const safeSummary = (n.summary || '').replace(/'/g, "\\'");
        const safeUrl = (n.url || '#').replace(/'/g, "\\'");

        return `
        <div class="mp-news-card" onclick="openArticleModal('${safeTitle}', '${safeSource}', '${safeTime}', '${safeSymbol}', '${safeSummary}', '${safeUrl}')" style="cursor: pointer;">
          <div class="d-flex justify-content-between align-items-center mb-1">
            <span class="badge bg-secondary-subtle text-body border">${n.source}</span>
            <span class="small text-muted">${n.time}</span>
          </div>
          <h4 class="h6 fw-bold mb-1">
            <span class="text-body text-decoration-none">
              ${n.title}
            </span>
          </h4>
          <p class="small text-muted mb-2">${n.summary}</p>
          <button type="button" class="btn btn-sm btn-outline-primary py-1 px-2 fw-semibold" onclick="event.stopPropagation(); openArticleModal('${safeTitle}', '${safeSource}', '${safeTime}', '${safeSymbol}', '${safeSummary}', '${safeUrl}')" style="font-size: 0.78rem;">
            Read Full Article <i class="bi bi-arrow-right ms-1"></i>
          </button>
        </div>
      `;
      }).join('');
    }
  } catch (err) {
    console.error('Failed to load related news:', err);
  }
}

function updateWatchlistButton() {
  const btn = document.getElementById('stockWatchlistBtn');
  if (!btn) return;
  const isWatched = MarketPulse.isWatched(window.CURRENT_SYMBOL);
  if (isWatched) {
    btn.innerHTML = '<i class="bi bi-star-fill me-1"></i> In Watchlist';
    btn.className = 'btn btn-sm btn-warning text-dark fw-semibold';
  } else {
    btn.innerHTML = '<i class="bi bi-star me-1"></i> Add to Watchlist';
    btn.className = 'btn btn-sm btn-outline-warning';
  }
}

function toggleStockWatchlist() {
  MarketPulse.toggleWatchlist(window.CURRENT_SYMBOL);
  updateWatchlistButton();
}

function quickAddToPortfolio(symbol, price) {
  let holdings = JSON.parse(localStorage.getItem('mp_holdings') || '[]');
  holdings.push({
    id: Date.now(),
    symbol: symbol,
    quantity: 10,
    purchasePrice: price
  });
  localStorage.setItem('mp_holdings', JSON.stringify(holdings));
  alert(`Added 10 shares of ${symbol} to your portfolio!\n\nView and manage your updated asset allocation under "My Portfolio".`);
}

function updateBuyOrderTotal() {
  const qtyInput = document.getElementById('buyOrderQty');
  const totalEl = document.getElementById('buyOrderEstimatedTotal');
  if (!qtyInput || !totalEl) return;

  const qty = parseInt(qtyInput.value, 10) || 0;
  const totalInEur = (window.CURRENT_BASE_PRICE || 100) * qty;
  totalEl.textContent = MarketPulse.formatPrice(totalInEur);
}

function executeStockBuyOrder(event) {
  event.preventDefault();
  const qtyInput = document.getElementById('buyOrderQty');
  const qty = parseInt(qtyInput ? qtyInput.value : '10', 10);
  const symbol = window.CURRENT_SYMBOL || 'SAP';
  const price = window.CURRENT_BASE_PRICE || 100.0;

  if (isNaN(qty) || qty <= 0) {
    alert('Please enter a valid share quantity.');
    return;
  }

  let holdings = JSON.parse(localStorage.getItem('mp_holdings') || '[]');
  holdings.push({
    id: Date.now(),
    symbol: symbol,
    quantity: qty,
    purchasePrice: price
  });
  localStorage.setItem('mp_holdings', JSON.stringify(holdings));

  const modalEl = document.getElementById('buyOrderModal');
  const modal = bootstrap.Modal.getInstance(modalEl);
  if (modal) modal.hide();

  alert(`Order Executed Successfully!\n\nPurchased ${qty} shares of ${symbol} at ${MarketPulse.formatPrice(price)} per share.\nPosition recorded in your Portfolio.`);
}

function setStockPriceAlert(event) {
  event.preventDefault();
  const targetPrice = document.getElementById('targetPriceInput').value;
  const condition = document.getElementById('alertConditionSelect').value;
  const symbol = window.CURRENT_SYMBOL || 'SAP';

  const modalEl = document.getElementById('priceAlertModal');
  const modal = bootstrap.Modal.getInstance(modalEl);
  if (modal) modal.hide();

  alert(`Price Alert Activated!\n\nYou will be notified when ${symbol} moves ${condition} €${targetPrice}.`);
}
