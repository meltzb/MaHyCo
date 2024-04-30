﻿// -*- tab-width: 2; indent-tabs-mode: nil; coding: utf-8-with-signature -*-
#include "IpgModule.h"

#include "arcane/ITimeLoopMng.h"
#include "arcane/IMesh.h"
#include "arcane/IItemFamily.h"
#include "arcane/IParticleFamily.h"

using namespace Arcane;
using namespace Arcane::Materials;

/*---------------------------------------------------------------------------*/
/**
 * \brief Constructeur du module
 */
/*---------------------------------------------------------------------------*/
IpgModule:: IpgModule(const ModuleBuildInfo& mbi) : 
  ArcaneIpgObject(mbi)
{
  auto* item_family = mesh()->createItemFamily (eItemKind::IK_Particle, "ActiveParticles");
  m_particles_family = item_family->toParticleFamily();
}

/*---------------------------------------------------------------------------*/
/**
 * \brief Création des particules
 */
/*---------------------------------------------------------------------------*/
void IpgModule::
createParticles()
{
  UniqueArray<Integer> lids({0,1,2}); //local Id
  UniqueArray<Int64> uids({0,1,2}); //unique Id
  info() << "Création des particules de localId " << lids.view();
  m_particles_family->addParticles(uids.view(), lids.view());
  m_particles_family->endUpdate();

  ENUMERATE_PARTICLE (part_i, m_particles_family->allItems()) {
    m_particle_coord[part_i] = Real3{0.5, 0.05, 0};
    m_particle_velocity[part_i] = options()->getInitVelocity();
    // m_particle_velocity[part_i] = options()->initVelocity(); // both work, I don't know which is best as programming practice
  }
}

/*---------------------------------------------------------------------------*/
/**
 * \brief Initialisation des sorties
 */
/*---------------------------------------------------------------------------*/
void IpgModule::
initParticleOutput()
{
  options()->getIpgOutput()->initOutput();
}

/*---------------------------------------------------------------------------*/
/**
 * \brief Mise à jour de la position des particule
 */
/*---------------------------------------------------------------------------*/
void IpgModule::
updateParticlePosition()
{
  Real deltat = m_global_deltat();
  ENUMERATE_PARTICLE (part_i, m_particles_family->allItems()) {
    m_particle_coord[part_i] += m_particle_velocity[part_i] * deltat;
    // info() << "Particle " << part_i.localId() << " new coord = " << m_particle_coord[part_i];
    info() << "Particle " << part_i.localId() << " vel = " << m_particle_velocity[part_i];
  }
}

/*---------------------------------------------------------------------------*/
/**
 * \brief Ecriture des sorties
 */
/*---------------------------------------------------------------------------*/
void IpgModule::
writeParticleOutput()
{

  // Pour test des sorties uniquement, en attendant que les variables soient calculées correctement
  ENUMERATE_PARTICLE(part_i, m_particles_family->allItems()) {
    m_particle_weight[part_i] = part_i.localId();
    m_particle_radius[part_i] = part_i.localId() * 2.0 ;
    m_particle_temperature[part_i] = options()->getInitTemperature();
  }
    
  options()->getIpgOutput()->writeOutput(m_particles_family->allItems());
}

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/

ARCANE_REGISTER_MODULE_IPG(IpgModule);
