% vim: ft=tex
\ProvidesClass{fsrprotokoll}[2018/03/05 Klasse fuer FSR Protokolle v0.2]
\LoadClass{scrartcl}

\RequirePackage[utf8]{inputenc}
\RequirePackage[ngerman]{babel}
\RequirePackage[T1]{fontenc}
\RequirePackage[a4paper,top=3cm,left=3cm,right=3cm,bottom=3cm]{geometry}
\RequirePackage{eurosym}
\RequirePackage{graphicx}
\RequirePackage{xifthen}
\RequirePackage{titlesec}
\RequirePackage{expl3}
\RequirePackage{xparse}
\RequirePackage{tabularx}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage[autostyle=true,german=quotes]{csquotes}
% https://github.com/AndyClifton/AccessibleMetaClass/blob/master/accessibilityMeta.sty
\RequirePackage[tagged]{accessibilityMeta}

\parindent 0pt
\parskip 1ex

\deffootnote[1em]{1em}{1em}{\textsuperscript{\thefootnotemark}}

\titleformat{\section}
  {\large\rmfamily\bfseries}
  {\thesection.}{0.5em}{}%
\titlespacing{\section}
  {0pt}
  {*1}
  {*0.25}
\titleformat{\subsection}
  {\normalfont\rmfamily\bfseries}
  {}{0em}{}
\titlespacing{\subsection}
  {0pt}
  {*0.5}
  {-5pt}

\makeatletter
\newcommand*{\insertheaderrule}{\rlap{\rule[-.5\normalbaselineskip]{\textwidth}{.4pt}}}
\def\ps@fsrProtokoll{%
    \def\@oddhead{\insertheaderrule%
      Protokoll zur FSR--Sitzung vom \the\date \hfill Fachschaftsrat Informatik%
    }
}
\def\ps@fsrProtokollTitlePage{%
    \def\@oddhead{\insertheaderrule%
      \includegraphics[height=4em]{fsrlogo}\hfill%
      \includegraphics[height=4em]{tudlogo}%
    }
}
\makeatother
\pagestyle{fsrProtokoll}

% counter for lists
\ExplSyntaxOn
\NewDocumentCommand \countItems { m } {
    \clist_count:N #1
}
\NewDocumentCommand \countInlineItems { m } {
    \clist_count:n {#1}
}
\ExplSyntaxOff

\newcommand{\quorate} {
  Die Sitzungsleitung eröffnet die Sitzung.
  \newcount\quorateThreshold
  \quorateThreshold=\the\numexpr (17 - \countItems{\resting})
  \divide\quorateThreshold by 2
  \ifthenelse{\the\attendeesNumber > \the\quorateThreshold\relax} {%
     Der FSR ist beschlussfähig.%
  } {%
    Der FSR ist nicht beschlussfähig.%
  }
}

\newcommand*{\quorum}[2] {
  \newcount\quorateThreshold
  \quorateThreshold=#2
  Es sind #1 von #2 Mitgliedern mit aktivem Stimmrecht anwesend.
  \divide\quorateThreshold by 2
  \ifthenelse{#1 > \the\quorateThreshold\relax} {%
     Der FSR ist somit beschlussfähig.%
  } {%
    Der FSR ist somit nicht beschlussfähig.%
  }
}

% titlepage
\renewcommand*{\maketitle}{%
  \begin{titlepage}%
    \thispagestyle{fsrProtokollTitlePage}
    \begin{center}%
      \vspace*{1cm}%
      \textbf{\Large Protokoll zur FSR--Sitzung vom \the\date}%

      Sitzungsleitung: \the\chairperson \,| %
      Protokoll: \the\clerks%

      Sitzungsbeginn: \the\meetingStart \,| Sitzungsende: \the\meetingEnd%
    \end{center}%

    \textbf{Anwesende:} \the\attendees% \, (\the\attendeesNumber \, von 17)%

    \textbf{Entschuldigt Fehlende:} \ifthenelse{\equal{\the\excused}{}} { $\emptyset$ } { \the\excused }%

    \textbf{Unentschuldigt Fehlende:} \ifthenelse{\equal{\the\unexcused}{}} { $\emptyset$ } { \the\unexcused }%

    \textbf{Ruhende:} \ifthenelse{\equal{\the\resting}{}} { $\emptyset$ } { \the\resting }%

    \textbf{Gäste:} \ifthenelse{\equal{\the\guests}{}} { $\emptyset$ } { \the\guests }%
    \vspace{\baselineskip}
    %\quorate  % automatische Feststellung der Beschlussfähigkeit
  \end{titlepage}%
  \hypersetup{%
    pdfauthor=Fachschaftsrat Informatik,
    pdftitle=Protokoll zur FSR-Sitzung vom \the\date
  }
}
\let\endtitlepage\relax

% vote environment
\newsavebox{\mybox}
\newcounter{x}  % counter to add up two arguments
\newenvironment{vote} {%
    \immediate\write\exportdata{-}
  \begin{lrbox}{\mybox}\begin{minipage}{.985\textwidth}
  \newcommand*{\voteNumber}[1]{%
    \immediate\write\exportdata{  decision_id: "\the\year/##1"}%
    \textbf{\the\year\,/\,##1:}\\%
  }%
  \newcommand*{\voteMoney}[1]{%
    \ifthenelse{\equal{##1}{}} {%
        \immediate\write\exportdata{  money_limit: NULL}%
        \textbf{Antrag}%
    } {%
        \immediate\write\exportdata{  money_limit: ##1}%
        \textbf{Finanzantrag}%
    }%
  }
  \newcommand{\voteText}[1]{%
      \immediate\write\exportdata{  text: "##1"}%
      ##1\vspace{\baselineskip}\\}%
  \newcommand*{\voteReason}[1]{%
      \immediate\write\exportdata{  rationale: "##1"}%
      \textbf{Begründung: }##1\vspace{\baselineskip}\\}%
  \newcommand*{\voting}[3]{\textbf{Abstimmung: }%
    \ifthenelse{\equal{##1}{} \AND \equal{##2}{} \AND \equal{##3}{}} {%
        \immediate\write\exportdata{  v_yes: 0}%
        \immediate\write\exportdata{  v_no: 0}%
        \immediate\write\exportdata{  v_neutral: 0}%
        \immediate\write\exportdata{  accepted: 1}%
      Der Antrag wurde ohne Gegenrede angenommen.%
    } {%
        \immediate\write\exportdata{  v_yes: ##1}%
        \immediate\write\exportdata{  v_no: ##2}%
        \immediate\write\exportdata{  v_neutral: ##3}%
      Dafür: ##1, Dagegen: ##2, Enthaltungen: ##3%
      \\%
      \setcounter{x}{##2+##3}%
      \ifnum##1>\arabic{x}%
        {%
            \immediate\write\exportdata{  accepted: 1}%
            Der Antrag wurde angenommen.
        }%
      \else%
        {
            \immediate\write\exportdata{  accepted: 0}%
            Der Antrag wurde abgelehnt.
        }%
      \fi%
    }%
  }%
  \newcommand*{\voteComment}[1]{%
      \immediate\write\exportdata{  comment: "##1"}%
        ##1
      }%
} {
  \end{minipage}\end{lrbox}\fbox{\usebox{\mybox}}
}

% poll environment
\newenvironment{poll} {%
  \begin{lrbox}{\mybox}\begin{minipage}{.985\textwidth}
  \newcommand*{\pollText}[1]{%
      \textbf{Standpunkt: } ##1\vspace{\baselineskip}\\%
    }%
    \newcommand*{\voting}[2]{%
      \textbf{Meinungsbild: } Dafür: ##1, Dagegen: ##2%
    }%
} {
  \end{minipage}\end{lrbox}\fbox{\usebox{\mybox}}
}

\newcommand*{\away}[1] {
    \ifthenelse{\the\numexpr \countInlineItems{#1} > 1} {%
        \textit{[#1 verlassen die Sitzung]}%
    } {%
        \textit{[#1 verlässt die Sitzung]}%
    }
}
\newcommand*{\appear}[1] {
    \ifthenelse{\the\numexpr \countInlineItems{#1} > 1} {%
        \textit{[#1 erscheinen zur Sitzung]}%
    } {%
        \textit{[#1 erscheint zur Sitzung]}%
    }
}
\newcommand*{\signature} {
  \vfill
  \noindent\rule{6.5cm}{0.3pt} \hfill \noindent\rule{6.5cm}{0.3pt}
  \noindent\makebox[6.5cm][l]{Sitzungsleitung} \hfill \noindent\makebox[6.5cm][l]{Protokoll}
}

\AtBeginDocument{%
  \immediate\newwrite\exportdata%
  \immediate\openout\exportdata=tmp.txt\relax
}

\AtEndDocument{%
  \immediate\write18{mv tmp.txt \the\date.yaml}
  \immediate\closeout\exportdata%
}

% tokens
\newtoks\date
\newtoks\attendeesNumber
\newtoks\chairperson
\newtoks\clerks
\newtoks\meetingStart
\newtoks\meetingEnd
\newtoks\attendees
\newtoks\excused
\newtoks\unexcused
\newtoks\resting
\newtoks\guests
\endinput

