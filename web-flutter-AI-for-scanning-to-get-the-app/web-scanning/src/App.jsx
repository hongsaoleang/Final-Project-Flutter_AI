import React, { useState, useEffect } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { 
  Download, 
  QrCode, 
  ShieldCheck, 
  Sparkles,
  Zap,
  Cpu,
  Users
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
    <div className="app-container">
      {/* Background ambient lighting */}
      <div className="ambient-glow glow-1"></div>
      <div className="ambient-glow glow-2"></div>

      {/* Header Bar */}
      <header className="header">
        <div className="logo-group">
          <div className="app-icon-wrapper">
            <img 
              src={appLogo} 
              alt="DER LENG AI Logo" 
              className="app-header-logo"
            />
          </div>
          <div>
            <div className="brand-title">DER LENG AI</div>
            <div className="brand-subtitle">Smart AI Mobile Assistant</div>
          </div>
        </div>

        <div className="header-meta">
          <div className="status-badge">
            <span className="pulsing-dot"></span>
            Ready for Install
          </div>
        </div>
      </header>

      {/* Main Grid */}
      <main className="content-grid">
        {/* Left Section: App details & Download */}
        <section className="app-details-card">
          <div className="tag-row">
            <span className="badge badge-primary"><Sparkles size={14} /> AI POWERED</span>
            <span className="badge badge-success"><ShieldCheck size={14} /> VERIFIED APK</span>
          </div>

          <div className="hero-branding-row">
            <div className="hero-logo-box">
              <img 
                src={appLogo} 
                alt="DER LENG AI Logo" 
                className="hero-logo-img" 
              />
            </div>
            <div>
              <h1 className="hero-heading">
                Install <span className="text-gradient">DER LENG AI</span>
              </h1>
              <p className="hero-subtitle">Official Android Package Release</p>
            </div>
          </div>

          <p className="hero-description">
            Get the full AI mobile experience on your Android phone. Tap download or scan the QR code to install directly on your device.
          </p>

          {/* Clean Specs Badges */}
          <div className="specs-grid">
            <div className="spec-box">
              <span className="spec-label">Platform</span>
              <span className="spec-value">Android</span>
            </div>
            <div className="spec-box">
              <span className="spec-label">Package</span>
              <span className="spec-value">APK File</span>
            </div>
            <div className="spec-box">
              <span className="spec-label">Security</span>
              <span className="spec-value text-success">Verified Safe</span>
            </div>
            <div className="spec-box">
              <span className="spec-label">Access</span>
              <span className="spec-value">Free</span>
            </div>
          </div>

          {/* Main Download CTA */}
          <div className="cta-action-group">
            <a 
              href={`/${apkFileName}`} 
              onClick={handleDownload}
              download={apkFileName} 
              className="download-btn-primary"
            >
              <Download size={24} className="btn-icon" />
              <div className="btn-text">
                <span className="btn-title">Download APK</span>
                <span className="btn-sub">Latest Build • 53.7 MB</span>
              </div>
            </a>
          </div>

          {/* Features Highlights */}
          <div className="features-list">
            <h3>App Features</h3>
            <div className="feature-item">
              <div className="feature-icon"><Zap size={16} /></div>
              <div>
                <strong>Live Vision & Scanner</strong>
                <p>Instant camera detection and OCR recognition.</p>
              </div>
            </div>
            <div className="feature-item">
              <div className="feature-icon"><Cpu size={16} /></div>
              <div>
                <strong>Smart AI Assistant</strong>
                <p>Intelligent responses and real-time conversation.</p>
              </div>
            </div>
          </div>
        </section>

        {/* Right Section: Clean QR Code Card */}
        <section className="qr-portal-card">
          <div className="qr-header">
            <div className="qr-badge">
              <QrCode size={18} />
              <span>Scan to Install APK</span>
            </div>
          </div>

          {/* QR Container */}
          <div className="qr-canvas-wrapper">
            <div className="scanner-corner top-left"></div>
            <div className="scanner-corner top-right"></div>
            <div className="scanner-corner bottom-left"></div>
            <div className="scanner-corner bottom-right"></div>
            
            <div className="qr-inner">
              <QRCodeSVG 
                value={apkDownloadUrl} 
                size={220} 
                level="M" 
                includeMargin={true}
                fgColor="#0f172a"
              />
            </div>
          </div>

          <p className="qr-instructions">
            Scan this QR code with your phone camera to download and install the app directly.
          </p>
        </section>
      </main>

      {/* Step by step install guide */}
      <section className="steps-container">
        <h2 className="steps-heading">How to Install on Android</h2>
        <div className="steps-grid">
          <div className={`step-card ${activeStep === 1 ? 'active' : ''}`} onClick={() => setActiveStep(1)}>
            <div className="step-number">1</div>
            <h4>Download</h4>
            <p>Scan the QR code or tap "Download APK" above.</p>
          </div>

          <div className={`step-card ${activeStep === 2 ? 'active' : ''}`} onClick={() => setActiveStep(2)}>
            <div className="step-number">2</div>
            <h4>Allow Install</h4>
            <p>If prompted by Android, tap "Allow from this source".</p>
          </div>

          <div className={`step-card ${activeStep === 3 ? 'active' : ''}`} onClick={() => setActiveStep(3)}>
            <div className="step-number">3</div>
            <h4>Open App</h4>
            <p>Tap install, then open to start using DER LENG AI.</p>
          </div>
        </div>
      </section>

      {/* Project Team Section (Under the last) */}
      <section className="team-container">
        <div className="team-header">
          <div className="team-badge">
            <Users size={16} />
            <span>CREDITS</span>
          </div>
          <h2 className="team-heading">Project Team</h2>
        </div>

        <div className="team-grid">
          {/* Hong Saoleang */}
          <div className="team-card">
            <div className="team-avatar-wrapper">
              <img 
                src={saoleangImg} 
                alt="Hong Saoleang" 
                className="team-avatar-img" 
              />
            </div>
            <div className="team-info">
              <h3 className="team-member-name">Hong Saoleang</h3>
              <div className="team-field">
                <span className="field-label">Role</span>
                <span className="field-value">Developer</span>
              </div>
              <div className="team-field">
                <span className="field-label">Tech</span>
                <span className="field-value">Flutter, Springboot, python AI</span>
              </div>
            </div>
          </div>

          {/* Peav Sengly */}
          <div className="team-card">
            <div className="team-avatar-wrapper">
              <img 
                src={senglyImg} 
                alt="Peav Sengly" 
                className="team-avatar-img" 
              />
            </div>
            <div className="team-info">
              <h3 className="team-member-name">Peav Sengly</h3>
              <div className="team-field">
                <span className="field-label">Role</span>
                <span className="field-value">Logo Designer</span>
              </div>
            </div>
          </div>

          {/* Vann Chandaravichhey */}
          <div className="team-card">
            <div className="team-avatar-wrapper">
              <img 
                src={chheyImg} 
                alt="Vann Chandaravichhey" 
                className="team-avatar-img" 
              />
            </div>
            <div className="team-info">
              <h3 className="team-member-name">Vann Chandaravichhey</h3>
              <div className="team-field">
                <span className="field-label">Role</span>
                <span className="field-value">Slide</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        DER LENG AI • Android APK Portal
      </footer>
    </div>
  );
}
