import React, { useState, useEffect } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { 
  Download, 
  QrCode, 
  ShieldCheck, 
  Sparkles,
  Camera,
  Compass,
  MapPin,
  CheckCircle2,
  Users,
  Smartphone,
  ArrowDown
} from 'lucide-react';
import appLogo from './assets/logo.png';
import saoleangImg from './assets/saoleang.jpg';
import senglyImg from './assets/sengly.jpg';
import chheyImg from './assets/chhey.jpg';
import './App.css';

export default function App() {
  const apkFileName = 'app-release.apk';
  const [apkDownloadUrl, setApkDownloadUrl] = useState(`http://192.168.100.219:5173/${apkFileName}`);
  const [activeStep, setActiveStep] = useState(1);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const host = window.location.hostname;
      const protocol = window.location.protocol;
      const port = window.location.port ? `:${window.location.port}` : '';
      
      let targetHost = host;
      if (host === 'localhost' || host === '127.0.0.1' || !host) {
        targetHost = typeof __DETECTED_LAN_IP__ !== 'undefined' ? __DETECTED_LAN_IP__ : '192.168.100.219';
      }
      
      setApkDownloadUrl(`${protocol}//${targetHost}${port}/${apkFileName}`);
    }
  }, []);

  const handleDownload = (e) => {
    e.preventDefault();
    const downloadLink = document.createElement('a');
    downloadLink.href = `/${apkFileName}?t=${Date.now()}`;
    downloadLink.setAttribute('download', apkFileName);
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
  };

  return (
    <div className="landing-wrapper">
      {/* Dynamic ambient lights */}
      <div className="glow-orb orb-top"></div>
      <div className="glow-orb orb-bottom"></div>

      {/* Navigation */}
      <header className="navbar">
        <div className="nav-brand">
          <img src={appLogo} alt="DER LENG AI" className="nav-logo" />
          <div className="nav-title-group">
            <span className="nav-title">DER LENG AI</span>
            <span className="nav-badge">v1.0</span>
          </div>
        </div>
        <div className="nav-actions">
          <div className="status-indicator">
            <span className="status-dot"></span>
            <span className="status-text">Android Ready</span>
          </div>
          <a href={`/${apkFileName}`} onClick={handleDownload} className="nav-cta-btn">
            <Download size={15} />
            <span>Download</span>
          </a>
        </div>
      </header>

      {/* Hero Header */}
      <section className="hero-section">
        <h1 className="hero-title">
          Explore Smarter with <span className="gradient-text">DER LENG AI</span>
        </h1>
      </section>

      {/* Main Download & QR Hub Card */}
      <section className="main-hub-card">
        <div className="hub-grid">
          {/* Left: Download & Overview */}
          <div className="hub-content">
            <div className="hub-meta-row">
              <span className="meta-tag meta-verified">
                <ShieldCheck size={14} /> Verified Safe
              </span>
              <span className="meta-tag meta-package">
                <Smartphone size={14} /> Android APK
              </span>
              <span className="meta-tag meta-size">53.7 MB</span>
            </div>

            <h2 className="hub-headline">Direct Android Installation</h2>
            <p className="hub-body">
              Download the release APK directly to your phone or scan the QR code to install in seconds.
            </p>

            <div className="hub-actions">
              <a 
                href={`/${apkFileName}`} 
                onClick={handleDownload} 
                className="primary-download-btn"
              >
                <div className="btn-icon-wrapper">
                  <Download size={22} />
                </div>
                <div className="btn-label-group">
                  <span className="btn-main-label">Download APK</span>
                  <span className="btn-sub-label">Android Release • 53.7 MB</span>
                </div>
              </a>
            </div>

            {/* Quick Feature Badges */}
            <div className="feature-badges-row">
              <div className="feature-badge-item">
                <div className="fb-icon"><Camera size={16} /></div>
                <div>
                  <h4>Live Vision & OCR</h4>
                  <p>Detect places & read text with camera</p>
                </div>
              </div>
              <div className="feature-badge-item">
                <div className="fb-icon"><Compass size={16} /></div>
                <div>
                  <h4>AI Travel Guide</h4>
                  <p>Smart itineraries & conversational answers</p>
                </div>
              </div>
            </div>
          </div>

          {/* Right: QR Code Scanner Portal */}
          <div className="hub-qr-panel">
            <div className="qr-card">
              <div className="qr-card-header">
                <QrCode size={18} className="qr-icon-accent" />
                <span>Scan with Camera</span>
              </div>

              <div className="qr-box">
                <div className="qr-bracket top-l"></div>
                <div className="qr-bracket top-r"></div>
                <div className="qr-bracket bot-l"></div>
                <div className="qr-bracket bot-r"></div>
                <div className="qr-svg-holder">
                  <QRCodeSVG 
                    value={apkDownloadUrl} 
                    size={190} 
                    level="M" 
                    includeMargin={true}
                    fgColor="#090d16"
                  />
                </div>
              </div>

              <p className="qr-hint">
                Scan code with phone camera to download directly.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Feature Showcase Grid */}
      <section className="features-section">
        <div className="section-title-wrap">
          <span className="section-label">CAPABILITIES</span>
          <h3 className="section-heading">Built for Travelers</h3>
        </div>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-card-icon"><Camera size={20} /></div>
            <h4>Instant Camera OCR</h4>
            <p>Scan street signs, menus, and landmarks with real-time translation and insights.</p>
          </div>

          <div className="feature-card">
            <div className="feature-card-icon"><Compass size={20} /></div>
            <h4>Intelligent Travel Guide</h4>
            <p>Ask questions and receive personalized recommendations for attractions and culture.</p>
          </div>

          <div className="feature-card">
            <div className="feature-card-icon"><MapPin size={20} /></div>
            <h4>Smart Map Discovery</h4>
            <p>Explore destinations, view live location updates, and discover local spots.</p>
          </div>
        </div>
      </section>

      {/* 3 Step Installation Flow */}
      <section className="steps-section">
        <div className="section-title-wrap">
          <span className="section-label">INSTALLATION</span>
          <h3 className="section-heading">Quick 3-Step Setup</h3>
        </div>

        <div className="steps-grid">
          <div 
            className={`step-card ${activeStep === 1 ? 'step-active' : ''}`}
            onClick={() => setActiveStep(1)}
          >
            <div className="step-num">01</div>
            <h4>Download</h4>
            <p>Scan the QR code or tap the Download button.</p>
          </div>

          <div 
            className={`step-card ${activeStep === 2 ? 'step-active' : ''}`}
            onClick={() => setActiveStep(2)}
          >
            <div className="step-num">02</div>
            <h4>Allow</h4>
            <p>If prompted, select "Allow from this source".</p>
          </div>

          <div 
            className={`step-card ${activeStep === 3 ? 'step-active' : ''}`}
            onClick={() => setActiveStep(3)}
          >
            <div className="step-num">03</div>
            <h4>Launch</h4>
            <p>Open the APK and enjoy DER LENG AI.</p>
          </div>
        </div>
      </section>

      {/* Project Team Section - CIRCULAR AVATARS & NAME ONLY */}
      <section className="team-section">
        <div className="section-title-wrap">
          <div className="team-pill">
            <Users size={13} />
            <span>CREDITS</span>
          </div>
          <h3 className="section-heading">Project Team</h3>
        </div>

        <div className="team-cards-grid">
          {/* Member 1: Hong Saoleang */}
          <div className="team-profile-card">
            <div className="avatar-circle-wrapper">
              <img 
                src={saoleangImg} 
                alt="Hong Saoleang" 
                className="avatar-circle-img" 
              />
            </div>
            <h4 className="member-name">Hong Saoleang</h4>
          </div>

          {/* Member 2: Peav Sengly */}
          <div className="team-profile-card">
            <div className="avatar-circle-wrapper">
              <img 
                src={senglyImg} 
                alt="Peav Sengly" 
                className="avatar-circle-img" 
              />
            </div>
            <h4 className="member-name">Peav Sengly</h4>
          </div>

          {/* Member 3: Vann Chandaravichhey */}
          <div className="team-profile-card">
            <div className="avatar-circle-wrapper">
              <img 
                src={chheyImg} 
                alt="Vann Chandaravichhey" 
                className="avatar-circle-img" 
              />
            </div>
            <h4 className="member-name">Vann Chandaravichhey</h4>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="page-footer">
        <p>DER LENG AI</p>
      </footer>
    </div>
  );
}
