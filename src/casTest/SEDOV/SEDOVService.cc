#include "SEDOVService.h"


void SEDOVService::initMatMono(Integer dim)  {
    
  ENUMERATE_CELL(icell,allCells()) {
    Cell cell = *icell;
    m_materiau[cell] = 0;
  }
}
void SEDOVService::initMat(Integer dim)  {

  if (options()->casTest == Sedov) {
    initMatMono(dim);
    return;
  }

  Real3 Xb={0.0, 0.0, 0.};
  ENUMERATE_CELL(icell,allCells()) {
    Cell cell = *icell;
    Real rmin(1.e-10);  // depot sur 1 maille
    Real rmax(0.);
    bool isCenterCell = false;  
    m_materiau[cell] = 0;
    ENUMERATE_NODE(inode, cell.nodes()) {
      Real rnode = std::sqrt((m_node_coord[inode].x - Xb.x) *
                                       (m_node_coord[inode].x- Xb.x) +
                                   (m_node_coord[inode].y- Xb.y) *
                                       (m_node_coord[inode].y - Xb.y)+
                                   (m_node_coord[inode].z- Xb.z) *
                                       (m_node_coord[inode].z - Xb.z));
      if (rnode < rmin) isCenterCell = true;
    }
    if (isCenterCell) {
      m_materiau[cell] = 1;
    }
  }
} 
void SEDOVService::initVarMono(Integer dim, Real3 densite_initiale, Real3 energie_initiale, Real3 pression_initiale, 
                                   Real3x3 vitesse_initiale)  {
    
  Real3 Xb={0.0, 0.0, 0.};
  Real rhoInit = densite_initiale[0];
  Real pInit = pression_initiale[0];
  Real e1 = 0.244816e-5;
  Real total_energy_deposit = 0.244816;
  Real rmin(1.e-10);  // depot sur 1 maille
  Real rnode(0.);
  
    
  ENUMERATE_CELL(icell,allCells()) {
    Cell cell = *icell;
    Real rmax(0.);
    bool isCenterCell = false;  
    m_internal_energy[cell] = e1;
    m_density[cell] = rhoInit;
    //m_pressure[cell] = 0.4 * rhoInit * e1;
    m_pressure[cell] = pInit;
    Real vol = m_cell_volume[cell]; 
    ENUMERATE_NODE(inode, cell.nodes()) {
        if (dim == 3) rnode = std::sqrt((m_node_coord[inode].x - Xb.x) *
                                       (m_node_coord[inode].x- Xb.x) +
                                   (m_node_coord[inode].y- Xb.y) *
                                       (m_node_coord[inode].y - Xb.y)+
                                   (m_node_coord[inode].z- Xb.z) *
                                       (m_node_coord[inode].z - Xb.z));
        else rnode = std::sqrt((m_node_coord[inode].x - Xb.x) *
                                       (m_node_coord[inode].x- Xb.x) +
                                   (m_node_coord[inode].y- Xb.y) *
                                       (m_node_coord[inode].y - Xb.y));
      if (rnode < rmin) isCenterCell = true;
    }
    if (isCenterCell) { 
      pinfo() << rmin << " cell " << cell.localId();
      m_internal_energy[cell] += total_energy_deposit / vol;
      m_pressure[cell] = 0.4 * rhoInit * m_internal_energy[cell];
    }
  }
  ENUMERATE_NODE(inode, allNodes()){
    m_velocity[inode] = {0.0, 0.0, 0.0};
  }
}
void SEDOVService::initVar(Integer dim, Real3 densite_initiale, Real3 energie_initiale, Real3 pression_initiale, 
                                   Real3x3 vitesse_initiale)  { 
  // pour l'instant meme fonction  que la version MonoMat

  if (options()->casTest == Sedov) {
    initVarMono(dim, densite_initiale, energie_initiale, pression_initiale, vitesse_initiale);
    return;
  }

  Real3 Xb={0.0, 0.0, 0.};
  Real rhoInit = densite_initiale[0];
  Real pInit = pression_initiale[0];
  Real e1 = 0.244816e-5;
  Real total_energy_deposit = 0.244816;
  Real rmin(1.e-10);  // depot sur 1 maille
  Real rnode(0.);
  
  ENUMERATE_CELL(icell,allCells()) {
    Cell cell = *icell;
    Real rmax(0.);
    bool isCenterCell = false;  
    // m_internal_energy[cell] = e1;
    m_density[cell] = rhoInit;
    // m_pressure[cell] = 0.4 * rhoInit * e1;
    m_pressure[cell] = pInit;
    
    Real vol = m_cell_volume[cell];
    ENUMERATE_NODE(inode, cell.nodes()) {
        if (dim == 3) rnode = std::sqrt((m_node_coord[inode].x - Xb.x) *
                                       (m_node_coord[inode].x- Xb.x) +
                                   (m_node_coord[inode].y- Xb.y) *
                                       (m_node_coord[inode].y - Xb.y)+
                                   (m_node_coord[inode].z- Xb.z) *
                                       (m_node_coord[inode].z - Xb.z));
        else rnode = std::sqrt((m_node_coord[inode].x - Xb.x) *
                                       (m_node_coord[inode].x- Xb.x) +
                                   (m_node_coord[inode].y- Xb.y) *
                                       (m_node_coord[inode].y - Xb.y));
      
      if (rnode < rmin) isCenterCell = true;
    }
    if (isCenterCell) { 
      m_internal_energy[cell] += total_energy_deposit / vol;
      m_pressure[cell] = 0.4 * rhoInit * m_internal_energy[cell];
    }
  }
  ENUMERATE_NODE(inode, allNodes()){
    m_velocity[inode] = {0.0, 0.0, 0.0};
  }
}
/*---------------------------------------------------------------------------*/

bool SEDOVService::hasReverseOption() { return options()->reverseOption;}
Real SEDOVService::getReverseParameter() { return options()->parametre;}
bool SEDOVService::isInternalModel() { return true ;}
void SEDOVService::initUtilisateur() { }
/*---------------------------------------------------------------------------*/


ARCANE_REGISTER_SERVICE_SEDOV(SEDOV, SEDOVService);
