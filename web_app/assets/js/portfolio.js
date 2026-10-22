/**
 * MarketPulse Portfolio Controller
 * Manages positions, P/L calculations, Chart.js allocation chart, and CRUD operations
 */

let allocationChart = null;

const DEFAULT_HOLDINGS = [
  { id: 1, symbol: 'SAP', quantity: 10, purchasePrice: 195.00 },
  { id: 2, symbol: 'BMW', quantity: 15, purchasePrice: 86.00 },
  { id: 3, symbol: 'SIE', quantity: 8, purchasePrice: 175.00 }
];

document.addEventListener('DOMContentLoaded', () => {
  initHoldings();
  bindAddHoldingForm();

  document.addEventListener('currencyChanged', () => {
    refreshPortfolioView();
  });

  // Automatically sync purchase price input when stock symbol changes in modal
  const symbolSelect = document.getElementById('holdingSymbol');
  const buyPriceInput = document.getElementById('holdingBuyPrice');
  if (symbolSelect && buyPriceInput) {
    symbolSelect.addEventListener('change', () => {
      const opt = symbolSelect.options[symbolSelect.selectedIndex];
      const p = opt.getAttribute('data-price');
      if (p) buyPriceInput.value = parseFloat(p).toFixed(2);
    });
  }

  renderInvestorBanner();
});

function renderInvestorBanner() {
  const banner = document.getElementById('investorProfileBanner');
  if (!banner) return;
  const rawUser = localStorage.getItem('mp_user');
  if (!rawUser) {
    banner.classList.add('d-none');
    return;
  }
  try {
    const user = JSON.parse(rawUser);
    banner.classList.remove('d-none');
    const nameEl = document.getElementById('bannerInvestorName');
    const accEl = document.getElementById('bannerAccountId');
    const tierEl = document.getElementById('bannerInvestorTier');
    const detailsEl = document.getElementById('bannerProfileDetails');

    if (nameEl) nameEl.textContent = user.name || 'Global Investor';
    if (accEl) accEl.textContent = user.accountId || 'MP-DEMO-01';
    if (tierEl) tierEl.innerHTML = `<i class="bi bi-patch-check-fill me-1"></i>${user.tier || 'Verified Investor'}`;
    if (detailsEl) {
      const citizen = user.citizenship ? `Citizenship: ${user.citizenship}` : 'Global Trader';
      const risk = user.riskTolerance ? `Risk: ${user.riskTolerance}` : 'Balanced';
      const exp = user.experience ? `Exp: ${user.experience}` : 'Intermediate';
      detailsEl.textContent = `${citizen} • ${risk} • ${exp} • Institutional Portfolio Node`;
    }
  } catch (e) {
    banner.classList.add('d-none');
  }
}

function getHoldings() {
  const saved = localStorage.getItem('mp_holdings');
  if (!saved) {
    localStorage.setItem('mp_holdings', JSON.stringify(DEFAULT_HOLDINGS));
    return DEFAULT_HOLDINGS;
  }
  try {
    return JSON.parse(saved);
  } catch (e) {
    return DEFAULT_HOLDINGS;
  }
}

function saveHoldings(list) {
  localStorage.setItem('mp_holdings', JSON.stringify(list));
  refreshPortfolioView();
}

function resetDemoHoldings() {
  localStorage.setItem('mp_holdings', JSON.stringify(DEFAULT_HOLDINGS));
  refreshPortfolioView();
}

function initHoldings() {
  refreshPortfolioView();
}

async function refreshPortfolioView() {
  const holdings = getHoldings();
  const tbody = document.getElementById('holdingsTableBody');
  if (!tbody) return;

  // Fetch current quotes for all distinct symbols
  const distinctSymbols = [...new Set(holdings.map(h => h.symbol))];
  const quotesMap = {};

  await Promise.all(distinctSymbols.map(async (sym) => {
    try {
      const res = await fetch(`api/stock.php?symbol=${encodeURIComponent(sym)}`);
      const json = await res.json();
      if (json.success) {
        quotesMap[sym] = json.data;
      }
    } catch (e) {
      console.error('Error fetching stock quote for portfolio:', sym, e);
    }
  }));

  let totalPortfolioValue = 0;
  let totalInvestedValue = 0;
  const allocationData = [];

  if (holdings.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="8" class="text-center py-4 text-muted">
          Your portfolio is empty. Click <strong>+ Add Investment</strong> above to add your first stock position!
        </td>
      </tr>
    `;
  } else {
    tbody.innerHTML = holdings.map(h => {
      const quote = quotesMap[h.symbol] || { price: h.purchasePrice, changePercent: 0 };
      const currentPrice = quote.price;
      const invested = h.quantity * h.purchasePrice;
      const currentVal = h.quantity * currentPrice;
      const pl = currentVal - invested;
      const plPercent = invested > 0 ? (pl / invested) * 100 : 0;
      const isPos = pl >= 0;

      totalPortfolioValue += currentVal;
      totalInvestedValue += invested;

      allocationData.push({
        symbol: h.symbol,
        value: currentVal
      });

      return `
        <tr>
          <td>
            <a href="stock.php?symbol=${encodeURIComponent(h.symbol)}" class="fw-bold text-dark text-decoration-none">
              ${h.symbol}
            </a>
          </td>
          <td class="fw-semibold">${h.quantity}</td>
          <td data-base-price="${h.purchasePrice}">${MarketPulse.formatPrice(h.purchasePrice)}</td>
          <td class="fw-bold" data-base-price="${currentPrice}">${MarketPulse.formatPrice(currentPrice)}</td>
          <td class="fw-bold" data-base-price="${currentVal}">${MarketPulse.formatPrice(currentVal)}</td>
          <td class="fw-bold ${isPos ? 'text-success' : 'text-danger'}">
            ${isPos ? '+' : ''}${MarketPulse.formatPrice(pl)}
          </td>
          <td>
            <span class="${isPos ? 'mp-badge-positive' : 'mp-badge-negative'}">
              ${isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'}${plPercent.toFixed(2)}%
            </span>
          </td>
          <td class="text-end">
            <button class="btn btn-sm btn-outline-primary py-0 px-2 me-1" onclick="openTradePositionModal(${h.id}, '${h.symbol}', ${h.quantity}, ${h.purchasePrice})" title="Purchase More Shares">
              <i class="bi bi-plus-lg me-1"></i>Buy
            </button>
            <button class="btn btn-sm btn-outline-danger py-0 px-2" onclick="deleteHolding(${h.id})" title="Remove Position">
              <i class="bi bi-trash3-fill"></i>
            </button>
          </td>
        </tr>
      `;
    }).join('');
  }

  // Update summary metrics
  const totalPL = totalPortfolioValue - totalInvestedValue;
  const totalPLPercent = totalInvestedValue > 0 ? (totalPL / totalInvestedValue) * 100 : 0;
  const isOverallPos = totalPL >= 0;

  const valEl = document.getElementById('totalPortfolioValue');
  const invEl = document.getElementById('totalInvestedValue');
  const plEl = document.getElementById('totalProfitLoss');
  const plPctEl = document.getElementById('totalProfitPercent');
  const countBadge = document.getElementById('holdingsBadge');
  const assetsCountEl = document.getElementById('totalAssetsCount');

  if (valEl) valEl.textContent = MarketPulse.formatPrice(totalPortfolioValue);
  if (invEl) invEl.textContent = MarketPulse.formatPrice(totalInvestedValue);
  if (plEl) {
    plEl.textContent = (isOverallPos ? '+' : '') + MarketPulse.formatPrice(totalPL);
    plEl.className = `fs-3 fw-bold mt-1 ${isOverallPos ? 'text-success' : 'text-danger'}`;
  }
  if (plPctEl) {
    plPctEl.innerHTML = `<span class="${isOverallPos ? 'mp-badge-positive' : 'mp-badge-negative'}">${isOverallPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'}${totalPLPercent.toFixed(2)}% Overall Return</span>`;
  }
  if (countBadge) countBadge.textContent = `${holdings.length} Position${holdings.length === 1 ? '' : 's'}`;
  if (assetsCountEl) assetsCountEl.textContent = holdings.length;

  renderAllocationChart(allocationData);
}

function renderAllocationChart(allocationList) {
  const canvas = document.getElementById('allocationChartCanvas');
  const legend = document.getElementById('allocationLegend');
  if (!canvas) return;

  // Group duplicate symbols if any
  const grouped = {};
  allocationList.forEach(item => {
    grouped[item.symbol] = (grouped[item.symbol] || 0) + item.value;
  });

  const labels = Object.keys(grouped);
  const data = Object.values(grouped);
  const palette = ['#2563EB', '#16A34A', '#F59E0B', '#8B5CF6', '#EC4899', '#06B6D4'];

  if (allocationChart) {
    allocationChart.destroy();
  }

  if (labels.length === 0) {
    if (legend) legend.innerHTML = '<span class="text-muted">No active allocation data.</span>';
    return;
  }

  allocationChart = new Chart(canvas.getContext('2d'), {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: data,
        backgroundColor: palette.slice(0, labels.length),
        borderWidth: 2,
        borderColor: '#FFFFFF'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
          labels: { font: { family: 'Inter', size: 12 }, boxWidth: 12 }
        },
        tooltip: {
          callbacks: {
            label: function(ctx) {
              const val = ctx.raw;
              const total = data.reduce((a, b) => a + b, 0);
              const pct = total > 0 ? ((val / total) * 100).toFixed(1) : 0;
              return ` ${ctx.label}: ${MarketPulse.formatPrice(val)} (${pct}%)`;
            }
          }
        }
      },
      cutout: '70%'
    }
  });
}

function bindAddHoldingForm() {
  const form = document.getElementById('addHoldingForm');
  if (!form) return;

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const symbol = document.getElementById('holdingSymbol').value;
    const qty = parseInt(document.getElementById('holdingQty').value, 10);
    const buyPrice = parseFloat(document.getElementById('holdingBuyPrice').value);

    if (!symbol || isNaN(qty) || qty <= 0 || isNaN(buyPrice) || buyPrice <= 0) {
      alert('Please enter valid quantity and purchase price.');
      return;
    }

    const holdings = getHoldings();
    holdings.push({
      id: Date.now(),
      symbol: symbol,
      quantity: qty,
      purchasePrice: buyPrice
    });

    saveHoldings(holdings);

    // Close modal
    const modalEl = document.getElementById('addHoldingModal');
    const modal = bootstrap.Modal.getInstance(modalEl);
    if (modal) modal.hide();
  });
}

function openTradePositionModal(id, symbol, qty, price) {
  document.getElementById('tradeHoldingId').value = id;
  document.getElementById('tradePositionSymbol').textContent = `${symbol} Position`;
  document.getElementById('tradeCurrentQty').textContent = `${qty} shares`;
  document.getElementById('tradeCurrentPrice').textContent = MarketPulse.formatPrice(price);
  document.getElementById('tradeAddQty').value = 5;
  document.getElementById('tradeExecutePrice').value = price.toFixed(2);

  const modalEl = document.getElementById('tradePositionModal');
  const modal = new bootstrap.Modal(modalEl);
  modal.show();
}

function executeTradePosition(event) {
  event.preventDefault();
  const id = parseInt(document.getElementById('tradeHoldingId').value, 10);
  const addQty = parseInt(document.getElementById('tradeAddQty').value, 10);
  const executePrice = parseFloat(document.getElementById('tradeExecutePrice').value);

  if (isNaN(addQty) || addQty <= 0 || isNaN(executePrice) || executePrice <= 0) {
    alert('Please enter valid additional shares and execution price.');
    return;
  }

  const holdings = getHoldings();
  const pos = holdings.find(h => h.id === id);
  if (!pos) return;

  const totalOldCost = pos.quantity * pos.purchasePrice;
  const totalNewCost = addQty * executePrice;
  const newQty = pos.quantity + addQty;
  const newAvgPrice = (totalOldCost + totalNewCost) / newQty;

  pos.quantity = newQty;
  pos.purchasePrice = parseFloat(newAvgPrice.toFixed(2));

  saveHoldings(holdings);

  const modalEl = document.getElementById('tradePositionModal');
  const modal = bootstrap.Modal.getInstance(modalEl);
  if (modal) modal.hide();

  alert(`Trade Executed! Purchased ${addQty} more shares of ${pos.symbol}.\nNew position: ${newQty} shares @ avg €${newAvgPrice.toFixed(2)}.`);
}

function deleteHolding(id) {
  if (!confirm('Are you sure you want to remove this position?')) return;
  const holdings = getHoldings().filter(h => h.id !== id);
  saveHoldings(holdings);
}
