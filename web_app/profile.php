<?php
$pageTitle = 'Investor Profile & Compliance Dossier - MarketPulse';
$currentPage = 'profile';
require_once __DIR__ . '/includes/header.php';
?>

<div class="container py-4">
    <!-- Logged Out Fallback State -->
    <div id="profileGuestState" class="d-none text-center py-5">
        <div class="mp-card max-w-md mx-auto p-5 shadow-sm" style="max-width: 540px; margin: 0 auto;">
            <div class="d-inline-flex p-3 rounded-circle bg-primary bg-opacity-10 text-primary mb-3">
                <i class="bi bi-person-badge fs-1"></i>
            </div>
            <h2 class="h4 fw-bold mb-2">Investor Profile Access</h2>
            <p class="text-muted small mb-4">Please sign in or complete the 5-step global onboarding flow to access your institutional dossier and verified brokerage status.</p>
            <div class="d-grid gap-2">
                <a href="auth.php" class="btn mp-btn-primary py-2 fw-bold">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to Terminal
                </a>
                <a href="kyc.php" class="btn btn-outline-secondary py-2">
                    <i class="bi bi-shield-check me-1"></i> Open Global Trading Account (5-Step KYC)
                </a>
            </div>
        </div>
    </div>

    <!-- Active Profile View -->
    <div id="profileActiveState">
        <!-- Hero Dossier Banner -->
        <div class="mp-card shadow-sm p-4 mb-4 border-0" style="background: linear-gradient(135deg, rgba(37, 99, 235, 0.08) 0%, rgba(16, 185, 129, 0.08) 100%); border-left: 5px solid var(--mp-secondary) !important;">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center shadow-sm" style="width: 64px; height: 64px; font-size: 1.6rem; font-weight: 800;" id="profileAvatar">
                        AV
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2 flex-wrap">
                            <h1 class="h4 fw-bold mb-0" id="profileName">Alexandra Vance</h1>
                            <span class="badge bg-success-subtle text-success small" id="profileTierBadge"><i class="bi bi-patch-check-fill me-1"></i>Tier 1 Verified Investor</span>
                            <span class="badge bg-primary-subtle text-primary font-monospace small" id="profileAccountId">MP-892410-GL</span>
                        </div>
                        <div class="text-muted small mt-1" id="profileSubHeader">
                            Institutional Account • Registered: <span id="profileDate">Active Session</span>
                        </div>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                        <i class="bi bi-pencil-square me-1"></i> Edit Profile
                    </button>
                    <a href="portfolio.php" class="btn btn-sm mp-btn-primary">
                        <i class="bi bi-pie-chart-fill me-1"></i> Trading Terminal
                    </a>
                    <button class="btn btn-sm btn-outline-danger" onclick="MarketPulse.signOut()">
                        <i class="bi bi-box-arrow-right"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- Quick Metrics Highlights -->
        <div class="row g-3 mb-4">
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="mp-card">
                    <span class="text-muted small fw-semibold">Virtual Buying Power</span>
                    <div class="fs-4 fw-bold mt-1 text-success" id="profileBalance">€100,000.00</div>
                    <div class="small text-muted mt-1"><i class="bi bi-shield-check text-success me-1"></i>Demo Clearing Node</div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="mp-card">
                    <span class="text-muted small fw-semibold">Compliance Status</span>
                    <div class="fs-4 fw-bold mt-1 text-primary">Cleared</div>
                    <div class="small text-muted mt-1"><i class="bi bi-file-earmark-check text-primary me-1"></i>W-8BEN Treaty Active</div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="mp-card">
                    <span class="text-muted small fw-semibold">Risk Classification</span>
                    <div class="fs-4 fw-bold mt-1" id="profileRiskMetric">Moderate</div>
                    <div class="small text-muted mt-1">Balanced Portfolio Safeguards</div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-3">
                <div class="mp-card">
                    <span class="text-muted small fw-semibold">Trading Experience</span>
                    <div class="fs-4 fw-bold mt-1" id="profileExpMetric">Intermediate</div>
                    <div class="small text-muted mt-1">Equities & Derivatives Enabled</div>
                </div>
            </div>
        </div>

        <!-- Detailed Dossier Cards Grid -->
        <div class="row g-4">
            <!-- Card 1: Legal Identity & Communication -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-person-vcard text-primary fs-5"></i>
                            <h2 class="h6 fw-bold mb-0">Legal Identity & Contact</h2>
                        </div>
                        <span class="badge bg-secondary-subtle text-secondary small">KYC Certified</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Official Name:</td>
                                <td class="fw-bold" id="detailFullName">Alexandra Vance</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Primary Email:</td>
                                <td class="fw-bold" id="detailEmail">a.vance@capitalgroup.com</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Registered Phone:</td>
                                <td id="detailPhone">+1 212-555-0149</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Date of Birth:</td>
                                <td id="detailDob">April 18, 1992</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Two-Factor Auth:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-shield-lock-fill me-1"></i>Enforced (SMS / Biometric)</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Card 2: Jurisdiction & Tax Compliance -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-globe-americas text-primary fs-5"></i>
                            <h2 class="h6 fw-bold mb-0">Citizenship & Tax Compliance</h2>
                        </div>
                        <span class="badge bg-success-subtle text-success small">OECD Reciprocal</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Citizenship:</td>
                                <td class="fw-bold" id="detailCitizenship">United States</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Tax Residency:</td>
                                <td class="fw-bold" id="detailTaxResidency">United States</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Tax ID / SSN:</td>
                                <td class="font-monospace" id="detailTaxId">US-••••-••-4091</td>
                            </tr>
                            <tr>
                                <td class="text-muted">IRS Form W-8BEN:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-check-circle-fill me-1"></i>Executed & Certified</span></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Regulatory Accord:</td>
                                <td class="small text-muted">SEC / FINRA Rule 15c3-1 & MiFID II Compliant</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Card 3: Financial Background & Suitability -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-wallet2 text-primary fs-5"></i>
                            <h2 class="h6 fw-bold mb-0">Financial Background & Suitability</h2>
                        </div>
                        <span class="badge bg-secondary-subtle text-secondary small">Tier 1 Bracket</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Employment Status:</td>
                                <td class="fw-bold" id="detailEmployment">Employed</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Industry Sector:</td>
                                <td id="detailIndustry">Banking & Financial Services</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Gross Annual Income:</td>
                                <td id="detailIncome">$100,000 - $250,000</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Liquid Net Worth:</td>
                                <td id="detailNetWorth">$150,000 - $500,000</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Source of Capital:</td>
                                <td id="detailFundSource">Employment Income / Salary</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Card 4: Investment Objectives & Multi-Market Coverage -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-compass text-primary fs-5"></i>
                            <h2 class="h6 fw-bold mb-0">Investment Profile & Markets</h2>
                        </div>
                        <span class="badge bg-primary-subtle text-primary small">Active Trader</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Experience Level:</td>
                                <td class="fw-bold" id="detailExperience">Intermediate (1-3 yrs)</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Primary Objective:</td>
                                <td id="detailObjective">Long-term Capital Growth</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Risk Tolerance:</td>
                                <td><span class="mp-risk-badge moderate" id="detailRiskBadge">Moderate</span></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Approved Exchanges:</td>
                                <td>
                                    <div class="d-flex flex-wrap gap-1 mt-1" id="detailMarkets">
                                        <span class="badge bg-light text-dark border">🇺🇸 NASDAQ/NYSE</span>
                                        <span class="badge bg-light text-dark border">🇪🇺 DAX/LSE</span>
                                        <span class="badge bg-light text-dark border">📊 Global ETFs</span>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-muted">Electronic Trading:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-lightning-charge-fill me-1"></i>Direct DMA Execution</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Security & Legal Notice -->
        <div class="p-3 rounded-3 bg-light border mt-4 text-muted small d-flex align-items-center justify-content-between flex-wrap gap-2">
            <div>
                <i class="bi bi-shield-check text-primary me-2"></i>
                <span>Data Protection: All investor dossier entries are cryptographically signed and stored in compliance with GDPR & SEC Regulation S-P.</span>
            </div>
            <a href="kyc.php" class="text-primary fw-semibold text-decoration-none">
                <i class="bi bi-shield-check me-1"></i> View / Re-certify KYC Clearance
            </a>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL: EDIT INVESTOR PROFILE               -->
<!-- ========================================== -->
<div class="modal fade" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="editProfileForm">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="editProfileModalLabel"><i class="bi bi-pencil-square me-2 text-primary"></i> Edit Profile Information</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="editName" class="form-label small fw-semibold">Legal Full Name</label>
                        <input type="text" class="form-control" id="editName" required>
                    </div>
                    <div class="mb-3">
                        <label for="editPhone" class="form-label small fw-semibold">Phone Number</label>
                        <input type="tel" class="form-control" id="editPhone" required>
                    </div>
                    <div class="mb-3">
                        <label for="editEmployment" class="form-label small fw-semibold">Employment Status</label>
                        <select class="form-select" id="editEmployment">
                            <option value="Employed">Employed (Salaried)</option>
                            <option value="Self-Employed">Self-Employed</option>
                            <option value="Professional Trader">Professional Trader</option>
                            <option value="Investor">Private Investor</option>
                            <option value="Retired">Retired</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="editIncome" class="form-label small fw-semibold">Annual Income Bracket</label>
                        <select class="form-select" id="editIncome">
                            <option value="Under $25,000">Under $25,000</option>
                            <option value="$25,000 - $50,000">$25,000 - $50,000</option>
                            <option value="$50,000 - $100,000">$50,000 - $100,000</option>
                            <option value="$100,000 - $250,000">$100,000 - $250,000</option>
                            <option value="Over $250,000">Over $250,000</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="editRisk" class="form-label small fw-semibold">Risk Tolerance</label>
                        <select class="form-select" id="editRisk">
                            <option value="Conservative">Conservative (Low Risk)</option>
                            <option value="Moderate">Moderate (Balanced Growth)</option>
                            <option value="Aggressive">Aggressive (High Alpha)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn mp-btn-primary btn-sm px-4 fw-bold">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    loadProfileData();

    // Handle Edit Profile Form
    const editForm = document.getElementById('editProfileForm');
    if (editForm) {
        editForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const raw = localStorage.getItem('mp_user') || '{}';
            let user = {};
            try { user = JSON.parse(raw); } catch (_) {}

            user.name = document.getElementById('editName').value.trim();
            user.phone = document.getElementById('editPhone').value.trim();
            user.employment = document.getElementById('editEmployment').value;
            user.annualIncome = document.getElementById('editIncome').value;
            user.riskTolerance = document.getElementById('editRisk').value;

            localStorage.setItem('mp_user', JSON.stringify(user));
            localStorage.setItem('mp_investor_profile', JSON.stringify(user));

            const modalEl = document.getElementById('editProfileModal');
            const modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) modal.hide();

            loadProfileData();
            if (typeof MarketPulse !== 'undefined' && MarketPulse.checkAuthStatus) {
                MarketPulse.checkAuthStatus();
            }
        });
    }
});

function loadProfileData() {
    const raw = localStorage.getItem('mp_user');
    const guestState = document.getElementById('profileGuestState');
    const activeState = document.getElementById('profileActiveState');

    if (!raw) {
        guestState.classList.remove('d-none');
        activeState.classList.add('d-none');
        return;
    }

    guestState.classList.add('d-none');
    activeState.classList.remove('d-none');

    let u = {};
    try {
        u = JSON.parse(raw);
    } catch (_) {
        u = {};
    }

    // Defaults for presentation
    const name = u.name || 'Alexandra Vance';
    const email = u.email || 'a.vance@capitalgroup.com';
    const phone = u.phone || '+1 212-555-0149';
    const accId = u.accountId || 'MP-892410-GL';
    const citizenship = u.citizenship || 'United States';
    const taxResidency = u.taxResidency || 'United States';
    const employment = u.employment || u.employmentStatus || 'Employed';
    const industry = u.industry || 'Banking & Financial Services';
    const income = u.annualIncome || '$100,000 - $250,000';
    const netWorth = u.netWorth || '$150,000 - $500,000';
    const fundSource = u.fundSource || 'Employment Income / Salary';
    const experience = u.experience || u.tradingExperience || 'Intermediate (1-3 yrs)';
    const risk = u.riskTolerance || 'Moderate';
    const objective = u.investmentObjective || 'Long-term Capital Growth';
    const tier = u.tier || 'Tier 1 Verified Investor';

    // Initials for avatar
    const initials = name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() || 'AV';
    document.getElementById('profileAvatar').textContent = initials;
    document.getElementById('profileName').textContent = name;
    document.getElementById('profileAccountId').textContent = accId;
    document.getElementById('profileTierBadge').innerHTML = `<i class="bi bi-patch-check-fill me-1"></i>${tier}`;

    // Highlights
    document.getElementById('profileRiskMetric').textContent = risk;
    document.getElementById('profileExpMetric').textContent = experience.split(' ')[0] || 'Intermediate';

    // Legal Identity
    document.getElementById('detailFullName').textContent = name;
    document.getElementById('detailEmail').textContent = email;
    document.getElementById('detailPhone').textContent = phone;

    // Jurisdiction
    document.getElementById('detailCitizenship').textContent = citizenship;
    document.getElementById('detailTaxResidency').textContent = taxResidency;
    if (u.taxId) {
        document.getElementById('detailTaxId').textContent = u.taxId.replace(/.(?=.{4})/g, '•');
    }

    // Financial
    document.getElementById('detailEmployment').textContent = employment;
    document.getElementById('detailIndustry').textContent = industry;
    document.getElementById('detailIncome').textContent = income;
    document.getElementById('detailNetWorth').textContent = netWorth;
    document.getElementById('detailFundSource').textContent = fundSource;

    // Objectives
    document.getElementById('detailExperience').textContent = experience;
    document.getElementById('detailObjective').textContent = objective;
    const riskBadge = document.getElementById('detailRiskBadge');
    riskBadge.textContent = risk;
    riskBadge.className = `mp-risk-badge ${risk.toLowerCase()}`;

    // Preferred Markets Chips
    const marketsContainer = document.getElementById('detailMarkets');
    if (marketsContainer) {
        const markets = Array.isArray(u.preferredMarkets) && u.preferredMarkets.length > 0
            ? u.preferredMarkets
            : ['US Equities', 'European Markets', 'Global ETFs'];
        marketsContainer.innerHTML = markets.map(m => `<span class="badge bg-light text-dark border">${m}</span>`).join('');
    }

    // Modal pre-fill
    document.getElementById('editName').value = name;
    document.getElementById('editPhone').value = phone;
    document.getElementById('editEmployment').value = employment;
    document.getElementById('editIncome').value = income;
    document.getElementById('editRisk').value = risk;
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
