#include "settingsbrowser.h"
#include "mainwindow.h"

#include <QWidget>
#include <QSplitter>
#include <QScrollArea>
#include <QList>
#include <QMainWindow>
#include <QMenu>
#include <QMenuBar>
#include <QApplication>

/******************************************************************************/
//
// Constructor for main window
//
/******************************************************************************/
MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent)
{
  QScrollArea *scrollarea;
  QSplitter *splitter;
  QList<int> default_sizes;
  QMenu *filemenu, *airfoilsmenu, *settingsmenu, *optimizemenu;
  QAction *quitact;
  QAction *managefoilsact;
  QAction *gotosettingsact, *optimact, *operact, *constract, *initact, *psoact,
          *gaact, *simplexact, *xfrunact, *xfpanact;
  QAction *gotooptimact;

  // Settings browser

  settingsbrowser = new SettingsBrowser(this);

  // Scroll area

  scrollarea = new QScrollArea(this);

  // Splitter (allows user to resize widgets)

  splitter = new QSplitter(this);
  splitter->setOrientation(Qt::Horizontal);
  splitter->addWidget(settingsbrowser);
  splitter->addWidget(scrollarea);
  
  // Default sizes for central widget items

  default_sizes.append(220);
  default_sizes.append(680); 
  splitter->setSizes(default_sizes);

  // Central widget
  
  setCentralWidget(splitter);

  // Actions for file menu

  quitact = new QAction("&Quit", this);

  // File menu

  filemenu = menuBar()->addMenu("&File");
  filemenu->addAction(quitact);

  // Actions for airfoils menu

  managefoilsact = new QAction("&Manage seed airfoils ...", this);

  // Airfoils menu

  airfoilsmenu = menuBar()->addMenu("&Airfoils");
  airfoilsmenu->addAction(managefoilsact);

  // Actions for settings menu

  gotosettingsact = new QAction("&Go to settings window ...", this);
  gotosettingsact->setEnabled(false);
  optimact = new QAction("&Optimization", this);
  operact = new QAction("Op&erating conditions", this);
  constract = new QAction("&Constraints", this);
  initact = new QAction("&Initialization", this);
  psoact = new QAction("&Particle swarm", this);
  gaact = new QAction("&Genetic algorithm", this); 
  simplexact = new QAction("Si&mplex search", this);
  xfrunact = new QAction("&Xfoil analysis", this);
  xfpanact = new QAction("X&foil paneling", this);

  // Settings menu

  settingsmenu = menuBar()->addMenu("&Settings");
  settingsmenu->addAction(gotosettingsact);
  settingsmenu->addAction(optimact);
  settingsmenu->addAction(operact);
  settingsmenu->addAction(constract);
  settingsmenu->addAction(initact);
  settingsmenu->addAction(psoact);
  settingsmenu->addAction(gaact);
  settingsmenu->addAction(simplexact);
  settingsmenu->addAction(xfrunact);
  settingsmenu->addAction(xfpanact);

  // Actions for optimization menu
 
  gotooptimact = new QAction("&Go to optimization window ...", this);
  gotooptimact->setEnabled(false);

  // Optimization menu
   
  optimizemenu = menuBar()->addMenu("&Optimization");
  optimizemenu->addAction(gotooptimact);

  // Connect signals/slots

  connect(quitact, &QAction::triggered, qApp, QApplication::quit);
}
