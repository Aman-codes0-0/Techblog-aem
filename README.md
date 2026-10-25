# TechBlog AEM — Enterprise CMS Architecture & Components

[![AEM as a Cloud Service](https://img.shields.io/badge/AEM-Cloud%20Ready-red.svg?logo=adobe)](https://experience.adobe.com/)
[![Java](https://img.shields.io/badge/Java-11%20LTS-orange.svg?logo=java)](https://adoptium.net/)
[![Maven](https://img.shields.io/badge/Maven-3.9-blue.svg?logo=apache-maven)](https://maven.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Aman%20Kumar-black.svg)](https://github.com/Aman-codes0-0)

A high-performance technical blog platform engineered for **Adobe Experience Manager (AEM as a Cloud Service)**.  
Featuring custom authorable components backed by **Apache Sling Models**, context-aware **HTL templating**, an **OSGi core bundle**, and a standalone **Live Interactive Web Showroom** with dark/light themes and real-time reading calculation.

---

## 🌟 Live Demo & Portfolio

- **Live Web Application:** [https://aman-codes0-0.github.io/Techblog-aem/](https://aman-codes0-0.github.io/Techblog-aem/)
- **Local Web Preview:** Simply open [`index.html`](index.html) in any modern browser — no AEM installation required!

---

## 🏗️ Architecture Overview

The repository follows Adobe's multi-module Maven reactor structure, enforcing a strict separation of concerns between backend domain logic (`core`) and JCR presentation packages (`ui.apps`).

```
techblog-aem/
├── index.html                                   # 🌐 Standalone Interactive Web App (Live Blog)
├── preview.html                                 # Standalone Component HTML Preview
├── pom.xml                                      # Root Maven Reactor (Dependency Management)
├── setup-and-deploy.bat                         # Automated One-Click Setup & Deploy Script
├── core/                                        # ⚙️ OSGi Bundle — Java Backend
│   ├── pom.xml                                  # OSGi Bundle packaging & Sling dependencies
│   └── src/main/java/com/techblog/core/models/
│       └── ArticleHeader.java                   # Sling Model: word-count read time & date format
└── ui.apps/                                     # 🎨 AEM Content Package — Frontend & Dialogs
    ├── pom.xml                                  # FileVault content package plugin
    └── src/main/content/
        ├── META-INF/vault/filter.xml            # JCR Path filters (/apps/techblog)
        └── jcr_root/apps/techblog/
            ├── clientlibs/clientlib-blog/       # Client library (techblog.blog)
            │   ├── css.txt
            │   └── css/blog.css                 # Theme styles (Black, White, Crimson Red)
            └── components/                      # Authorable AEM Components
                ├── articleheader/               # Title, author, date, read time, body
                ├── authorbio/                   # Bio card with GitHub & LinkedIn links
                ├── codesnippet/                 # Monospace syntax block with language badge
                └── tagslist/                    # Dynamic multi-value pill tag list
```

### Data Flow & Component Wiring

```
   [ AEM Sites Author / Dialog ]
                 │
                 ▼  (Stores properties into JCR)
        [ JCR Node / Content ]
                 │
                 ▼  (ValueMap injected via @ValueMapValue)
    [ Sling Model: ArticleHeader.java ]
                 │   - Computes: getReadTime() (words ÷ 200 WPM)
                 │   - Computes: getFormattedDate() ("dd MMM yyyy")
                 ▼
    [ HTL Template: articleheader.html ]  <── [ Clientlib: blog.css ]
                 │
                 ▼
   [ Rendered HTML Page in Browser ]
```

---

## 🧩 Components Specification

| Component | Backend Model / Data | Dialog Fields | Key Features |
|---|---|---|---|
| **Article Header** | `ArticleHeader.java` (`@Model`) | Title, Author, Date, Body | Computes dynamic reading duration (e.g. `4 min read`) based on word count. |
| **Code Snippet** | JCR `ValueMap` | Language, Code text | Monospace font, language badge, copy-to-clipboard functionality. |
| **Author Bio** | JCR `ValueMap` | Name, Bio, GitHub, LinkedIn | Highlighted card with conditional social link rendering (`data-sly-test`). |
| **Tags List** | Multi-value Array | Array of string tags | Pill-styled responsive tags with hover animations. |

---

## 🚀 Running the Project

### Option A: View the Standalone Live Site (No AEM Required)
1. Double-click [`index.html`](index.html) or run:
   ```powershell
   Start-Process index.html
   ```
2. Features included in the web app:
   - 🌓 **Dark / Light Mode Toggle** with `localStorage` persistence.
   - 📊 **Reading Progress Bar** that tracks scroll depth.
   - 📋 **Copy Code Button** with animated feedback.
   - 👏 **Interactive Claps & Likes** counters.
   - 🔗 **Social Share Suite** (Copy Link, X/Twitter, LinkedIn, WhatsApp).
   - 📑 **Scroll-Spy Table of Contents** sidebar.
   - 🔍 **AEM Architecture Inspector Modal** for technical reviews.

---

### Option B: Deploy to Local AEM SDK Instance

#### Prerequisites:
- Java JDK 11 ([Adoptium Temurin](https://adoptium.net/))
- Apache Maven 3.6+
- AEM as a Cloud Service Quickstart SDK

#### 1. Start your local AEM instance:
```bash
java -jar aem-sdk-quickstart-*.jar -r author,localDev -gui
```

#### 2. Run the automated deployment:
Double-click `setup-and-deploy.bat` or run:
```bash
mvn clean install -PautoInstallSinglePackage
```

#### 3. Verify in AEM:
1. Open the OSGi console at `http://localhost:4502/system/console/bundles`.
2. Confirm bundle `com.techblog.core` is in **ACTIVE** status.
3. Open **Sites** -> Create/Edit a Page -> Open Layout Container Policy -> Enable the **"Tech Blog"** component group.

---

## 🌐 Deploy to GitHub Pages (Free Live Hosting)

To make your blog accessible to anyone over the internet:

1. Push this repository to GitHub:
   ```bash
   git init
   git add .
   git commit -m "feat: complete AEM TechBlog architecture and interactive web app"
   git branch -M main
   git remote add origin https://github.com/<YOUR-USERNAME>/techblog-aem.git
   git push -u origin main
   ```
2. On GitHub, go to your repository **Settings** -> **Pages**.
3. Under **Build and deployment** -> **Branch**, select `main` and root `/`, then click **Save**.
4. Within 1 minute, your blog will be live at:
   `https://aman-codes0-0.github.io/Techblog-aem/`

---

## 💼 Resume & Interview Highlights

### Resume Bullet Points:
- **TechBlog AEM (Adobe Experience Manager):** Engineered a modular, enterprise-grade publishing system on AEM Cloud Service using Java 11, Apache Sling Models, and OSGi.
- **Dynamic Sling Model:** Built `ArticleHeader.java` utilizing `@Model` and `@ValueMapValue` annotations to process JCR content and compute estimated read times dynamically.
- **HTL & Clientlibs:** Created lightweight, context-aware HTL templates paired with modular clientlibs, achieving zero-dependency frontends with built-in XSS protection.
- **Build Automation:** Configured multi-module Maven POMs with `filevault-package-maven-plugin` and `maven-bundle-plugin` for continuous local deployment.

### Key Technical Interview Q&A:

<details>
<summary><strong>Q: What is the purpose of Apache Sling Models?</strong></summary>
Sling Models are annotation-driven Java "POJOs" that map JCR resource properties into Java objects automatically. They eliminate legacy scriptlet/JSP business logic and provide testable, reusable business layers.
</details>

<details>
<summary><strong>Q: Why use <code>DefaultInjectionStrategy.OPTIONAL</code>?</strong></summary>
By default, Sling Models throw an exception if an injected field does not exist in the JCR. Marking strategy as optional ensures components render gracefully even if the content author hasn't filled in every dialog field yet.
</details>

<details>
<summary><strong>Q: How does HTL provide security over traditional JSP?</strong></summary>
HTL automatically enforces context-aware XSS escaping (HTML, attribute, URI, JS string) based on the syntax context, making code secure by default without manual sanitizer tags.
</details>

---

## 👤 Author

**Aman Kumar**  
AEM Engineer & Full Stack Developer  
- **GitHub:** [@Aman-codes0-0](https://github.com/Aman-codes0-0)
- **LinkedIn:** [Aman Kumar](https://linkedin.com)  
