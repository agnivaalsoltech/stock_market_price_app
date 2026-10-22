/**
 * MarketPulse Global Application JavaScript
 * Manages Currency State, Location Detection, and Common DOM Formatters
 */

const MarketPulse = {
  currency: localStorage.getItem('mp_currency') || 'EUR',
  rates: { EUR: 1.0, USD: 1.09, GBP: 0.85, INR: 91.20 },
  symbols: { EUR: '€', USD: '$', GBP: '£', INR: '₹' },
  currentCountry: localStorage.getItem('mp_country') || 'Germany',
  countryCurrencies: {
    'Germany': 'EUR',
    'USA': 'USD',
    'United Kingdom': 'GBP',
    'UK': 'GBP',
    'India': 'INR'
  },

  theme: localStorage.getItem('mp_theme') || 'light',

  init() {
    this.initTheme();
    this.syncCountryFromUrl();
    this.bindCurrencySelector();
    this.bindCountrySelector();
    this.initGeolocation();
    this.updatePricesOnPage();
    this.checkAuthStatus();
  },

  syncCountryFromUrl() {
    const urlParams = new URLSearchParams(window.location.search);
    const urlCountry = urlParams.get('country');
    if (urlCountry && this.countryCurrencies[urlCountry]) {
      this.setCountry(urlCountry, true);
    }
  },

  initTheme() {
    document.documentElement.setAttribute('data-theme', this.theme);
    const btn = document.getElementById('mpThemeToggle');
    if (btn) {
      btn.innerHTML = this.theme === 'dark' ? '<i class="bi bi-sun-fill text-warning"></i>' : '<i class="bi bi-moon-stars-fill"></i>';
      btn.addEventListener('click', () => {
        this.theme = this.theme === 'dark' ? 'light' : 'dark';
        localStorage.setItem('mp_theme', this.theme);
        document.documentElement.setAttribute('data-theme', this.theme);
        btn.innerHTML = this.theme === 'dark' ? '<i class="bi bi-sun-fill text-warning"></i>' : '<i class="bi bi-moon-stars-fill"></i>';
        document.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: this.theme } }));
      });
    }
  },

  getWatchlist() {
    try {
      return JSON.parse(localStorage.getItem('mp_watchlist') || '["SAP"]');
    } catch (_) {
      return ['SAP'];
    }
  },

  toggleWatchlist(symbol) {
    const list = this.getWatchlist();
    const idx = list.indexOf(symbol);
    if (idx > -1) {
      list.splice(idx, 1);
    } else {
      list.push(symbol);
    }
    localStorage.setItem('mp_watchlist', JSON.stringify(list));
    document.dispatchEvent(new CustomEvent('watchlistChanged', { detail: { symbol, watchlist: list } }));
    return list.includes(symbol);
  },

  isWatched(symbol) {
    return this.getWatchlist().includes(symbol);
  },

  setCurrency(curr) {
    if (!this.rates[curr]) return;
    this.currency = curr;
    localStorage.setItem('mp_currency', curr);
    const select = document.getElementById('mpCurrencySelect');
    if (select && select.value !== curr) {
      select.value = curr;
    }
    this.updatePricesOnPage();
    document.dispatchEvent(new CustomEvent('currencyChanged', { detail: { currency: curr } }));
  },

  setCountry(country, autoUpdateCurrency = true) {
    if (!country) return;
    this.currentCountry = country;
    localStorage.setItem('mp_country', country);

    // Sync navbar country select
    const navCountrySelect = document.getElementById('mpNavbarCountrySelect');
    if (navCountrySelect && navCountrySelect.value !== country) {
      navCountrySelect.value = country;
    }

    // Sync location badge if present
    const locationBadge = document.getElementById('mpLocationBadge');
    if (locationBadge) {
      locationBadge.innerHTML = `<i class="bi bi-geo-alt-fill text-danger me-1"></i> ${country} <i class="bi bi-caret-down-fill small ms-1"></i>`;
    }

    // Sync country select quick on home page if present
    const homeSelect = document.getElementById('countrySelectQuick');
    if (homeSelect && homeSelect.value !== country) {
      homeSelect.value = country;
    }

    // Sync markets filter select if present
    const marketsSelect = document.getElementById('countryFilterSelect');
    if (marketsSelect && marketsSelect.value !== country) {
      marketsSelect.value = country;
    }

    // Automatically update the currency to match the country's native currency
    if (autoUpdateCurrency) {
      const targetCurrency = this.countryCurrencies[country] || 'EUR';
      this.setCurrency(targetCurrency);
    }

    document.dispatchEvent(new CustomEvent('countryChanged', { detail: { country, currency: this.currency } }));
  },

  formatPrice(amountInEur) {
    const rate = this.rates[this.currency] || 1.0;
    const converted = amountInEur * rate;
    const sym = this.symbols[this.currency] || '€';
    return `${sym}${converted.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  },

  formatRawNumber(num) {
    return num.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  },

  bindCountrySelector() {
    const select = document.getElementById('mpNavbarCountrySelect');
    if (select) {
      select.value = this.currentCountry;
      select.addEventListener('change', (e) => {
        const newCountry = e.target.value;
        this.setCountry(newCountry, true);
        if (window.location.pathname.includes('markets.php')) {
          window.location.href = 'markets.php?country=' + encodeURIComponent(newCountry);
        }
      });
    }
  },

  bindCurrencySelector() {
    const select = document.getElementById('mpCurrencySelect');
    if (select) {
      select.value = this.currency;
      select.addEventListener('change', (e) => {
        this.setCurrency(e.target.value);
      });
    }
  },

  updatePricesOnPage() {
    const priceElements = document.querySelectorAll('[data-base-price]');
    priceElements.forEach(el => {
      const baseEur = parseFloat(el.getAttribute('data-base-price'));
      if (!isNaN(baseEur)) {
        el.textContent = this.formatPrice(baseEur);
      }
    });

    // Update currency labels
    const currLabels = document.querySelectorAll('.mp-curr-symbol');
    currLabels.forEach(el => {
      el.textContent = this.symbols[this.currency];
    });
  },

  initGeolocation() {
    const locationBadge = document.getElementById('mpLocationBadge');
    if (!locationBadge) return;

    // Check if user previously manual selected
    if (localStorage.getItem('mp_country')) {
      this.currentCountry = localStorage.getItem('mp_country');
      locationBadge.innerHTML = `<i class="bi bi-geo-alt-fill text-danger me-1"></i> ${this.currentCountry} <i class="bi bi-caret-down-fill small ms-1"></i>`;
      return;
    }

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          if (lat > 40 && lat < 55) {
            this.currentCountry = 'Germany';
          } else if (lat >= 25 && lat <= 40) {
            this.currentCountry = 'USA';
          } else {
            this.currentCountry = 'Germany';
          }
          localStorage.setItem('mp_country', this.currentCountry);
          locationBadge.innerHTML = `<i class="bi bi-geo-alt-fill text-danger me-1"></i> ${this.currentCountry} <i class="bi bi-caret-down-fill small ms-1"></i>`;
        },
        (error) => {
          console.log('Location permission denied or unavailable, using default fallback: Germany');
          locationBadge.innerHTML = `<i class="bi bi-geo-alt-fill text-danger me-1"></i> ${this.currentCountry} <i class="bi bi-caret-down-fill small ms-1"></i>`;
        },
        { timeout: 5000 }
      );
    } else {
      locationBadge.innerHTML = `<i class="bi bi-geo-alt-fill text-danger me-1"></i> ${this.currentCountry} <i class="bi bi-caret-down-fill small ms-1"></i>`;
    }
  },

  checkAuthStatus() {
    const user = localStorage.getItem('mp_user');
    const container = document.getElementById('mpAuthNavContainer');
    if (!container) return;

    if (user) {
      try {
        const u = JSON.parse(user);
        const isPro = localStorage.getItem('mp_is_pro') === 'true';
        const accId = u.accountId ? `<span class="badge bg-secondary-subtle text-secondary small font-monospace">${u.accountId}</span>` : '';
        container.innerHTML = `
          <div class="dropdown">
            <button class="btn btn-sm btn-outline-light dropdown-toggle d-flex align-items-center gap-1" type="button" data-bs-toggle="dropdown" aria-expanded="false">
              <span class="badge ${isPro ? 'bg-warning text-dark' : 'bg-primary'}">${isPro ? '<i class="bi bi-patch-check-fill me-1"></i>PRO' : '<i class="bi bi-person-fill"></i>'}</span>
              <span>${u.name || 'Account'}</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow">
              <li><h6 class="dropdown-header mb-0">${u.name || 'Investor Account'}</h6></li>
              <li><div class="px-3 py-1 small text-muted font-monospace">${u.accountId || u.email || ''}</div></li>
              ${u.kycVerified ? '<li><div class="px-3 pb-1"><span class="badge bg-success-subtle text-success small"><i class="bi bi-check-circle-fill me-1"></i>Verified Global Investor</span></div></li>' : ''}
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item d-flex align-items-center gap-2" href="profile.php"><i class="bi bi-person-bounding-box text-primary"></i> My Investor Profile</a></li>
              <li><a class="dropdown-item d-flex align-items-center gap-2" href="portfolio.php"><i class="bi bi-pie-chart-fill text-primary"></i> My Portfolio</a></li>
              <li><a class="dropdown-item d-flex align-items-center gap-2" href="pro.php"><i class="bi bi-star-fill text-warning"></i> Pro Membership</a></li>
              <li><a class="dropdown-item d-flex align-items-center gap-2" href="kyc.php"><i class="bi bi-shield-check text-secondary"></i> Onboarding / KYC Status</a></li>
              <li><hr class="dropdown-divider"></li>
              <li><button class="dropdown-item text-danger d-flex align-items-center gap-2" onclick="MarketPulse.signOut()"><i class="bi bi-box-arrow-right"></i> Sign Out</button></li>
            </ul>
          </div>
        `;
      } catch (e) {
        container.innerHTML = `<a id="mpAuthNav" href="auth.php" class="btn btn-sm btn-outline-light">Sign In</a>`;
      }
    } else {
      container.innerHTML = `<a id="mpAuthNav" href="auth.php" class="btn btn-sm btn-outline-light">Sign In</a>`;
    }
  },

  signOut() {
    localStorage.removeItem('mp_user');
    window.location.href = 'index.php';
  }
};

window.openArticleModal = function(title, source, time, symbol, summary, url) {
  const titleEl = document.getElementById('readerTitle');
  const metaEl = document.getElementById('readerMeta');
  const symEl = document.getElementById('readerSymbol');
  const summaryEl = document.getElementById('readerSummary');
  const stockLinkEl = document.getElementById('readerStockLink');
  const extLinkEl = document.getElementById('readerExternalLink');

  if (titleEl) titleEl.textContent = title || '';
  if (metaEl) metaEl.textContent = (source || '') + ' • ' + (time || '');
  if (symEl) symEl.textContent = symbol || 'INDEX';
  if (summaryEl) summaryEl.textContent = summary || '';
  if (stockLinkEl) stockLinkEl.href = 'stock.php?symbol=' + encodeURIComponent(symbol || '');
  if (extLinkEl) extLinkEl.href = url || '#';

  const modalEl = document.getElementById('articleReaderModal');
  if (modalEl && typeof bootstrap !== 'undefined') {
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
  }
};

document.addEventListener('DOMContentLoaded', () => {
  MarketPulse.init();
});


