<?php
$pageTitle = 'Regulatory KYC & Investor Onboarding - MarketPulse';
$currentPage = 'kyc';
require_once __DIR__ . '/includes/header.php';
?>

<div class="container py-4">
    <!-- Header Brand Banner -->
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div>
            <div class="d-flex align-items-center gap-2">
                <h1 class="h3 fw-bold mb-0">Regulatory KYC & Onboarding Portal</h1>
                <span class="badge bg-success-subtle text-success small" id="kycStatusHeaderBadge">
                    <i class="bi bi-patch-check-fill me-1"></i>Tier 1 Verified
                </span>
            </div>
            <p class="text-muted small mb-0">Cross-border investor suitability, identity clearance, and W-8BEN tax certification</p>
        </div>
        <div class="d-flex gap-2">
            <a href="profile.php" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-person-bounding-box me-1"></i> View Profile
            </a>
            <a href="portfolio.php" class="btn mp-btn-primary btn-sm">
                <i class="bi bi-pie-chart-fill me-1"></i> Trading Terminal
            </a>
        </div>
    </div>

    <!-- Active KYC Clearance Certificate (Shown when user has completed onboarding) -->
    <div id="kycVerifiedView" class="d-none">
        <div class="mp-card shadow-sm p-4 mb-4 border-0" style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.08) 0%, rgba(37, 99, 235, 0.08) 100%); border-left: 5px solid var(--mp-positive) !important;">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center shadow-sm" style="width: 58px; height: 58px; font-size: 1.6rem;">
                        <i class="bi bi-shield-fill-check"></i>
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2 flex-wrap">
                            <h2 class="h5 fw-bold mb-0" id="kycCertifiedName">Alexandra Vance</h2>
                            <span class="badge bg-success text-white small">CLEARANCE ACTIVE</span>
                        </div>
                        <div class="text-muted small mt-1">
                            Certificate ID: <span class="font-monospace fw-bold text-primary" id="kycReferenceId">KYC-US-FINRA-892410</span> • Cleared via Cross-Border Reciprocal Protocol
                        </div>
                    </div>
                </div>
                <div>
                    <button type="button" class="btn btn-sm btn-outline-primary" id="btnLaunchRecertify">
                        <i class="bi bi-arrow-repeat me-1"></i> Update / Re-certify KYC
                    </button>
                </div>
            </div>
        </div>

        <!-- Clearance Details Grid -->
        <div class="row g-4 mb-4">
            <!-- Col 1: Identity & Verification Records -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex justify-content-between align-items-center">
                        <span class="fw-bold"><i class="bi bi-fingerprint text-primary me-2"></i>Verified Identity Records</span>
                        <span class="badge bg-success-subtle text-success small">Level 3 Cleared</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Official Name:</td>
                                <td class="fw-bold" id="recFullName">Alexandra Vance</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Primary Email:</td>
                                <td class="fw-bold" id="recEmail">a.vance@capitalgroup.com</td>
                            </tr>
                            <tr>
                                <td class="text-muted">2FA Phone:</td>
                                <td id="recPhone">+1 212-555-0149</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Government ID Status:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-check-circle-fill me-1"></i>Passport / Gov ID Verified</span></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Screening Check:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-shield-check me-1"></i>AML / PEP Cleared</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Col 2: Regulatory Tax Declaration -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex justify-content-between align-items-center">
                        <span class="fw-bold"><i class="bi bi-bank text-primary me-2"></i>Tax Jurisdiction & Treaty Clearance</span>
                        <span class="badge bg-primary-subtle text-primary small">IRS W-8BEN / FATCA</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Citizenship:</td>
                                <td class="fw-bold" id="recCitizenship">United States</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Tax Residency:</td>
                                <td class="fw-bold" id="recTaxResidency">United States</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Tax Identification:</td>
                                <td class="font-monospace" id="recTaxId">US-••••-••-4091</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Form W-8BEN Treaty:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-patch-check-fill me-1"></i>Certified & On File</span></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Cross-Border Accord:</td>
                                <td class="small text-muted">SEC / FINRA Rule 15c3-1 & MiFID II Compliant</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Col 3: Suitability & Risk Assessment -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex justify-content-between align-items-center">
                        <span class="fw-bold"><i class="bi bi-graph-up-arrow text-primary me-2"></i>Suitability Assessment</span>
                        <span class="badge bg-warning-subtle text-warning small">Active Parameters</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Employment:</td>
                                <td class="fw-bold" id="recEmployment">Employed • Banking & Finance</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Annual Income:</td>
                                <td id="recIncome">$100,000 - $250,000</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Trading Experience:</td>
                                <td id="recExperience">Intermediate (1-3 yrs)</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Risk Tolerance:</td>
                                <td><span class="mp-risk-badge moderate" id="recRiskBadge">Moderate</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Col 4: Clearing Account & Electronic Authority -->
            <div class="col-12 col-lg-6">
                <div class="mp-card h-100">
                    <div class="mp-card-header d-flex justify-content-between align-items-center">
                        <span class="fw-bold"><i class="bi bi-file-earmark-lock text-primary me-2"></i>Custody & Execution Authority</span>
                        <span class="badge bg-secondary-subtle text-secondary small">Direct DMA Access</span>
                    </div>
                    <table class="table table-sm mp-summary-table align-middle">
                        <tbody>
                            <tr>
                                <td class="text-muted" style="width: 40%;">Account ID:</td>
                                <td class="font-monospace fw-bold text-primary" id="recAccountId">MP-892410-GL</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Virtual Buying Power:</td>
                                <td class="fw-bold text-success" id="recBalance">€100,000.00 (Allocated)</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Margin Facility:</td>
                                <td><span class="badge bg-success-subtle text-success"><i class="bi bi-check me-1"></i>Approved (2x Intraday)</span></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Electronic Signatures:</td>
                                <td><span class="badge bg-light text-dark border">Consented & Timestamped</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- KYC Onboarding / Re-certification Wizard Container -->
    <div id="kycWizardView" class="mp-card shadow-lg p-4 p-md-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="badge bg-primary-subtle text-primary fw-semibold px-2 py-1" id="stepCounterBadge">Step 1 of 5: Account & Security</span>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-sm btn-outline-secondary" id="btnPrefillKycDemo">
                    <i class="bi bi-magic me-1"></i> Prefill Sample KYC
                </button>
                <button type="button" class="btn btn-sm btn-outline-danger d-none" id="btnCancelRecertify">
                    Cancel Re-certification
                </button>
            </div>
        </div>

        <!-- Stepper Visual Indicators -->
        <div class="mp-stepper-container">
            <div class="mp-step-item active" id="stepIndicator1">
                <div class="mp-step-circle">1</div>
                <span class="mp-step-label">Account</span>
            </div>
            <div class="mp-step-item" id="stepIndicator2">
                <div class="mp-step-circle">2</div>
                <span class="mp-step-label">Citizenship</span>
            </div>
            <div class="mp-step-item" id="stepIndicator3">
                <div class="mp-step-circle">3</div>
                <span class="mp-step-label">Financials</span>
            </div>
            <div class="mp-step-item" id="stepIndicator4">
                <div class="mp-step-circle">4</div>
                <span class="mp-step-label">Objectives</span>
            </div>
            <div class="mp-step-item" id="stepIndicator5">
                <div class="mp-step-circle">5</div>
                <span class="mp-step-label">Review</span>
            </div>
        </div>

        <!-- Progress Bar -->
        <div class="progress mb-4" style="height: 6px;">
            <div class="progress-bar bg-primary progress-bar-striped progress-bar-animated" id="flowProgressBar" role="progressbar" style="width: 20%;"></div>
        </div>

        <!-- Alerts -->
        <div id="kycAlert" class="alert d-none small mb-4" role="alert"></div>

        <!-- Multi-Step Form Wizard -->
        <form id="kycWizardForm" novalidate>
            <!-- STEP 1: ACCOUNT & CREDENTIALS -->
            <div class="wizard-step" id="wizardStep1">
                <h5 class="fw-bold mb-1"><i class="bi bi-person-bounding-box text-primary me-2"></i>Account & Security Credentials</h5>
                <p class="text-muted small mb-4">Provide legal identification and security credentials for institutional clearing clearance.</p>

                <div class="row g-3">
                    <div class="col-12 col-md-6">
                        <label for="regFullName" class="form-label small fw-semibold">Legal Full Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="regFullName" placeholder="e.g. Alexandra Vance" required>
                        <div class="form-text small">Must match passport or official national ID</div>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regEmail" class="form-label small fw-semibold">Institutional / Contact Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="regEmail" placeholder="investor@capitalgroup.com" required>
                        <div class="form-text small">Primary trading terminal identifier</div>
                    </div>

                    <div class="col-12 col-md-4">
                        <label for="regPhoneCode" class="form-label small fw-semibold">Country Code</label>
                        <select class="form-select" id="regPhoneCode">
                            <option value="+1" selected>🇺🇸 US/CA (+1)</option>
                            <option value="+44">🇬🇧 UK (+44)</option>
                            <option value="+49">🇩🇪 Germany (+49)</option>
                            <option value="+91">🇮🇳 India (+91)</option>
                            <option value="+81">🇯🇵 Japan (+81)</option>
                            <option value="+33">🇫🇷 France (+33)</option>
                            <option value="+41">🇨🇭 Switzerland (+41)</option>
                            <option value="+65">🇸🇬 Singapore (+65)</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-8">
                        <label for="regPhoneNumber" class="form-label small fw-semibold">Mobile Phone (2FA SMS) <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="regPhoneNumber" placeholder="e.g. 212-555-0149" required>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="regPassword" class="form-label small fw-semibold">Security Password <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="regPassword" placeholder="Min 6 characters" value="Investor2026!" required minlength="6">
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regConfirmPassword" class="form-label small fw-semibold">Confirm Password <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="regConfirmPassword" placeholder="Repeat password" value="Investor2026!" required minlength="6">
                    </div>
                </div>
            </div>

            <!-- STEP 2: CITIZENSHIP & TAX RESIDENCY -->
            <div class="wizard-step d-none" id="wizardStep2">
                <h5 class="fw-bold mb-1"><i class="bi bi-globe-americas text-primary me-2"></i>Citizenship & Regulatory Tax Jurisdiction</h5>
                <p class="text-muted small mb-4">Required under SEC Rule 15c3-1, MiFID II suitability, and IRS Form W-8BEN.</p>

                <div class="row g-3">
                    <div class="col-12 col-md-6">
                        <label for="regCitizenship" class="form-label small fw-semibold">Country of Citizenship <span class="text-danger">*</span></label>
                        <select class="form-select" id="regCitizenship" required>
                            <option value="United States" selected>🇺🇸 United States</option>
                            <option value="Germany">🇩🇪 Germany</option>
                            <option value="United Kingdom">🇬🇧 United Kingdom</option>
                            <option value="India">🇮🇳 India</option>
                            <option value="Japan">🇯🇵 Japan</option>
                            <option value="Switzerland">🇨🇭 Switzerland</option>
                            <option value="France">🇫🇷 France</option>
                            <option value="Singapore">🇸🇬 Singapore</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regTaxResidency" class="form-label small fw-semibold">Primary Tax Residency <span class="text-danger">*</span></label>
                        <select class="form-select" id="regTaxResidency" required>
                            <option value="United States" selected>🇺🇸 United States</option>
                            <option value="Germany">🇩🇪 Germany</option>
                            <option value="United Kingdom">🇬🇧 United Kingdom</option>
                            <option value="India">🇮🇳 India</option>
                            <option value="Japan">🇯🇵 Japan</option>
                            <option value="Switzerland">🇨🇭 Switzerland</option>
                            <option value="France">🇫🇷 France</option>
                            <option value="Singapore">🇸🇬 Singapore</option>
                        </select>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="regDob" class="form-label small fw-semibold">Date of Birth (18+ Required) <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="regDob" value="1992-04-18" required>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regTaxId" class="form-label small fw-semibold">Tax ID / SSN / PAN <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="regTaxId" value="US-928-11-4091" required>
                    </div>
                </div>
            </div>

            <!-- STEP 3: FINANCIAL BACKGROUND -->
            <div class="wizard-step d-none" id="wizardStep3">
                <h5 class="fw-bold mb-1"><i class="bi bi-wallet2 text-primary me-2"></i>Financial Background & Suitability</h5>
                <p class="text-muted small mb-4">Required by global broker-dealers to establish investor suitability thresholds.</p>

                <div class="row g-3">
                    <div class="col-12 col-md-6">
                        <label for="regEmployment" class="form-label small fw-semibold">Employment Status</label>
                        <select class="form-select" id="regEmployment">
                            <option value="Employed" selected>Employed (Salaried Corporate)</option>
                            <option value="Self-Employed">Self-Employed / Founder</option>
                            <option value="Professional Trader">Professional Market Trader</option>
                            <option value="Investor">Private Capital Investor</option>
                            <option value="Retired">Retired</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regIndustry" class="form-label small fw-semibold">Industry Sector</label>
                        <select class="form-select" id="regIndustry">
                            <option value="Banking & Financial Services" selected>Banking & Financial Services</option>
                            <option value="Technology & Software">Technology & Software</option>
                            <option value="Healthcare & Pharma">Healthcare & Pharma</option>
                            <option value="Engineering & Energy">Engineering & Energy</option>
                            <option value="Consulting & Legal">Consulting & Legal</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regIncome" class="form-label small fw-semibold">Gross Annual Income</label>
                        <select class="form-select" id="regIncome">
                            <option value="Under $25,000">Under $25,000</option>
                            <option value="$25,000 - $50,000">$25,000 - $50,000</option>
                            <option value="$50,000 - $100,000">$50,000 - $100,000</option>
                            <option value="$100,000 - $250,000" selected>$100,000 - $250,000</option>
                            <option value="Over $250,000">Over $250,000</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regNetWorth" class="form-label small fw-semibold">Estimated Liquid Net Worth</label>
                        <select class="form-select" id="regNetWorth">
                            <option value="Under $50,000">Under $50,000</option>
                            <option value="$50,000 - $150,000">$50,000 - $150,000</option>
                            <option value="$150,000 - $500,000" selected>$150,000 - $500,000</option>
                            <option value="$500,000 - $1,000,000">$500,000 - $1,000,000</option>
                            <option value="Over $1,000,000">Over $1,000,000</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- STEP 4: OBJECTIVES & RISK -->
            <div class="wizard-step d-none" id="wizardStep4">
                <h5 class="fw-bold mb-1"><i class="bi bi-compass text-primary me-2"></i>Trading Profile & Risk Objectives</h5>
                <p class="text-muted small mb-4">Configures risk safeguards and execution routing parameters.</p>

                <div class="row g-3">
                    <div class="col-12 col-md-6">
                        <label for="regExperience" class="form-label small fw-semibold">Trading Experience</label>
                        <select class="form-select" id="regExperience">
                            <option value="Beginner (< 1 yr)">Beginner (< 1 yr)</option>
                            <option value="Intermediate (1-3 yrs)" selected>Intermediate (1-3 yrs)</option>
                            <option value="Advanced (3+ yrs)">Advanced (3+ yrs / Professional)</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-6">
                        <label for="regRisk" class="form-label small fw-semibold">Risk Tolerance Profile</label>
                        <select class="form-select" id="regRisk">
                            <option value="Conservative">Conservative (Capital Preservation)</option>
                            <option value="Moderate" selected>Moderate (Balanced Growth)</option>
                            <option value="Aggressive">Aggressive (High Alpha Swings)</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <label for="regObjective" class="form-label small fw-semibold">Primary Investment Objective</label>
                        <select class="form-select" id="regObjective">
                            <option value="Long-term Capital Growth" selected>Long-term Capital Growth</option>
                            <option value="Dividends & Passive Yield">Dividends & Passive Yield</option>
                            <option value="Active Day Trading & Hedging">Active Day Trading & Hedging</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- STEP 5: REGULATORY REVIEW & SIGNATURE -->
            <div class="wizard-step d-none" id="wizardStep5">
                <h5 class="fw-bold mb-1"><i class="bi bi-shield-check text-primary me-2"></i>Compliance Review & Certification</h5>
                <p class="text-muted small mb-3">Confirm and certify your international regulatory agreements.</p>

                <div class="border rounded-3 p-3 bg-light mb-3">
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" id="checkKycW8" required checked>
                        <label class="form-check-label small" for="checkKycW8">
                            <strong>IRS Form W-8BEN / FATCA Treaty Certification:</strong> I certify under penalties of perjury that I am the beneficial owner of the account and the tax declarations submitted are true, correct, and complete.
                        </label>
                    </div>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" id="checkKycRisk" required checked>
                        <label class="form-check-label small" for="checkKycRisk">
                            <strong>Securities & Exchange Risk Disclosure:</strong> I understand that equity and multi-market securities trading carries the risk of principal loss.
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="checkKycTerms" required checked>
                        <label class="form-check-label small" for="checkKycTerms">
                            <strong>Electronic Signature & Brokerage Mandate:</strong> I consent to electronic execution of brokerage records and agree to MarketPulse terms.
                        </label>
                    </div>
                </div>
            </div>

            <!-- Step Navigation -->
            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                <button type="button" class="btn btn-outline-secondary px-4" id="btnPrevStep" disabled>
                    <i class="bi bi-arrow-left me-1"></i> Back
                </button>
                <button type="button" class="btn mp-btn-primary px-4 fw-bold" id="btnNextStep">
                    Continue <i class="bi bi-arrow-right ms-1"></i>
                </button>
                <button type="submit" class="btn btn-success px-4 fw-bold d-none" id="btnSubmitKyc">
                    <i class="bi bi-check-circle-fill me-1"></i> Complete & Certify KYC
                </button>
            </div>
        </form>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    initKycPage();
});

let currentKycStep = 1;
const totalKycSteps = 5;

const stepTitles = [
    "Step 1 of 5: Account & Security",
    "Step 2 of 5: Citizenship & Tax",
    "Step 3 of 5: Financials & Suitability",
    "Step 4 of 5: Objectives & Risk Profile",
    "Step 5 of 5: Review & Compliance Certification"
];

function initKycPage() {
    const raw = localStorage.getItem('mp_user');
    let user = null;
    try { if (raw) user = JSON.parse(raw); } catch (_) {}

    const verifiedView = document.getElementById('kycVerifiedView');
    const wizardView = document.getElementById('kycWizardView');
    const headerBadge = document.getElementById('kycStatusHeaderBadge');
    const btnCancelRecertify = document.getElementById('btnCancelRecertify');

    if (user && user.kycVerified) {
        // Show Clearance Certificate View
        verifiedView.classList.remove('d-none');
        wizardView.classList.add('d-none');
        headerBadge.className = 'badge bg-success-subtle text-success small';
        headerBadge.innerHTML = '<i class="bi bi-patch-check-fill me-1"></i>Tier 1 Verified';

        // Populate Certificate values
        document.getElementById('kycCertifiedName').textContent = user.name || 'Alexandra Vance';
        document.getElementById('kycReferenceId').textContent = 'KYC-' + (user.accountId || 'MP-892410-GL');
        document.getElementById('recFullName').textContent = user.name || 'Alexandra Vance';
        document.getElementById('recEmail').textContent = user.email || 'a.vance@capitalgroup.com';
        document.getElementById('recPhone').textContent = user.phone || '+1 212-555-0149';
        document.getElementById('recCitizenship').textContent = user.citizenship || 'United States';
        document.getElementById('recTaxResidency').textContent = user.taxResidency || 'United States';
        document.getElementById('recTaxId').textContent = user.taxId ? user.taxId.replace(/.(?=.{4})/g, '•') : 'US-••••-4091';
        document.getElementById('recEmployment').textContent = (user.employment || 'Employed') + ' • ' + (user.industry || 'Banking & Finance');
        document.getElementById('recIncome').textContent = user.annualIncome || '$100,000 - $250,000';
        document.getElementById('recExperience').textContent = user.experience || 'Intermediate (1-3 yrs)';
        document.getElementById('recAccountId').textContent = user.accountId || 'MP-892410-GL';

        const riskBadge = document.getElementById('recRiskBadge');
        const risk = user.riskTolerance || 'Moderate';
        riskBadge.textContent = risk;
        riskBadge.className = `mp-risk-badge ${risk.toLowerCase()}`;

        // Populate Form fields with existing data in case user clicks Re-certify
        prefillFormFromUser(user);
    } else {
        // Show Wizard View directly
        verifiedView.classList.add('d-none');
        wizardView.classList.remove('d-none');
        headerBadge.className = 'badge bg-warning-subtle text-warning small';
        headerBadge.innerHTML = '<i class="bi bi-hourglass-split me-1"></i>Pending Verification';
    }

    // Launch Re-certification button
    const btnLaunchRecertify = document.getElementById('btnLaunchRecertify');
    if (btnLaunchRecertify) {
        btnLaunchRecertify.addEventListener('click', () => {
            verifiedView.classList.add('d-none');
            wizardView.classList.remove('d-none');
            if (btnCancelRecertify) btnCancelRecertify.classList.remove('d-none');
            showStep(1);
        });
    }

    // Cancel Re-certification
    if (btnCancelRecertify) {
        btnCancelRecertify.addEventListener('click', () => {
            verifiedView.classList.remove('d-none');
            wizardView.classList.add('d-none');
        });
    }

    // Prefill Sample KYC button
    const btnPrefill = document.getElementById('btnPrefillKycDemo');
    if (btnPrefill) {
        btnPrefill.addEventListener('click', () => {
            document.getElementById('regFullName').value = 'Alexandra Vance';
            document.getElementById('regEmail').value = 'a.vance@capitalgroup.com';
            document.getElementById('regPhoneNumber').value = '212-555-0149';
            document.getElementById('regCitizenship').value = 'United States';
            document.getElementById('regTaxResidency').value = 'United States';
            document.getElementById('regTaxId').value = 'US-928-11-4091';
            document.getElementById('regEmployment').value = 'Employed';
            document.getElementById('regIncome').value = '$100,000 - $250,000';
            document.getElementById('regRisk').value = 'Moderate';
            showKycAlert('Sample KYC profile loaded into form.', true);
        });
    }

    bindStepButtons();
}

function prefillFormFromUser(user) {
    if (!user) return;
    if (user.name) document.getElementById('regFullName').value = user.name;
    if (user.email) document.getElementById('regEmail').value = user.email;
    if (user.phone) {
        const parts = user.phone.split(' ');
        if (parts.length > 1) {
            document.getElementById('regPhoneNumber').value = parts.slice(1).join(' ');
        } else {
            document.getElementById('regPhoneNumber').value = user.phone;
        }
    }
    if (user.citizenship) document.getElementById('regCitizenship').value = user.citizenship;
    if (user.taxResidency) document.getElementById('regTaxResidency').value = user.taxResidency;
    if (user.taxId) document.getElementById('regTaxId').value = user.taxId;
    if (user.annualIncome) document.getElementById('regIncome').value = user.annualIncome;
    if (user.riskTolerance) document.getElementById('regRisk').value = user.riskTolerance;
}

function showKycAlert(msg, isSuccess = true) {
    const alertBox = document.getElementById('kycAlert');
    alertBox.className = `alert small mb-4 ${isSuccess ? 'alert-success' : 'alert-danger'}`;
    alertBox.innerHTML = (isSuccess ? '<i class="bi bi-check-circle-fill me-2"></i>' : '<i class="bi bi-exclamation-triangle-fill me-2"></i>') + msg;
    alertBox.classList.remove('d-none');
}

function showStep(stepNumber) {
    for (let i = 1; i <= totalKycSteps; i++) {
        const stepEl = document.getElementById(`wizardStep${i}`);
        const indicatorEl = document.getElementById(`stepIndicator${i}`);
        if (stepEl) stepEl.classList.toggle('d-none', i !== stepNumber);
        if (indicatorEl) {
            indicatorEl.classList.remove('active', 'completed');
            if (i === stepNumber) indicatorEl.classList.add('active');
            else if (i < stepNumber) indicatorEl.classList.add('completed');
        }
    }
    currentKycStep = stepNumber;
    document.getElementById('stepCounterBadge').textContent = stepTitles[stepNumber - 1];
    document.getElementById('flowProgressBar').style.width = `${(stepNumber / totalKycSteps) * 100}%`;

    const btnPrev = document.getElementById('btnPrevStep');
    const btnNext = document.getElementById('btnNextStep');
    const btnSubmit = document.getElementById('btnSubmitKyc');

    btnPrev.disabled = (currentKycStep === 1);
    if (currentKycStep === totalKycSteps) {
        btnNext.classList.add('d-none');
        btnSubmit.classList.remove('d-none');
    } else {
        btnNext.classList.remove('d-none');
        btnSubmit.classList.add('d-none');
    }
}

function bindStepButtons() {
    const btnPrev = document.getElementById('btnPrevStep');
    const btnNext = document.getElementById('btnNextStep');
    const form = document.getElementById('kycWizardForm');

    btnNext.addEventListener('click', () => {
        if (currentKycStep === 1) {
            const name = document.getElementById('regFullName').value.trim();
            const email = document.getElementById('regEmail').value.trim();
            if (!name || !email.includes('@')) {
                showKycAlert('Please provide your legal full name and a valid email.', false);
                return;
            }
        }
        document.getElementById('kycAlert').classList.add('d-none');
        if (currentKycStep < totalKycSteps) {
            showStep(currentKycStep + 1);
        }
    });

    btnPrev.addEventListener('click', () => {
        if (currentKycStep > 1) {
            showStep(currentKycStep - 1);
        }
    });

    form.addEventListener('submit', (e) => {
        e.preventDefault();
        const raw = localStorage.getItem('mp_user') || '{}';
        let user = {};
        try { user = JSON.parse(raw); } catch (_) {}

        user.name = document.getElementById('regFullName').value.trim();
        user.email = document.getElementById('regEmail').value.trim();
        user.phone = document.getElementById('regPhoneCode').value + ' ' + document.getElementById('regPhoneNumber').value.trim();
        user.citizenship = document.getElementById('regCitizenship').value;
        user.taxResidency = document.getElementById('regTaxResidency').value;
        user.taxId = document.getElementById('regTaxId').value.trim();
        user.employment = document.getElementById('regEmployment').value;
        user.annualIncome = document.getElementById('regIncome').value;
        user.riskTolerance = document.getElementById('regRisk').value;
        user.accountId = user.accountId || ('MP-' + Math.floor(100000 + Math.random() * 900000) + '-GL');
        user.kycVerified = true;
        user.authenticated = true;
        user.virtualBalance = user.virtualBalance || 100000;

        localStorage.setItem('mp_user', JSON.stringify(user));
        localStorage.setItem('mp_investor_profile', JSON.stringify(user));

        showKycAlert('KYC Verification and Cross-Border Certification Approved!', true);
        setTimeout(() => {
            initKycPage();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }, 600);
    });
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
