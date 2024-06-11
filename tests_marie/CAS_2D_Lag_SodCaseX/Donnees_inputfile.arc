<?xml version='1.0'?>
<case codeversion="1.0" codename="Mahyco" xml:lang="en">
  <arcane>
    <title>CAS_2D_Lag_SodCaseX</title>
    <timeloop>MahycoLagrangeLoop</timeloop>
    <modules>
      <module name="ArcanePostProcessing" active="true" />
      <module name="Ipg" active="true"/>
    </modules>
  </arcane>

  <arcane-post-processing>
    <output>
      <variable>CellMass</variable>
      <variable>Pressure</variable>
      <variable>Density</variable>
      <variable>Velocity</variable>
      <variable>NodeMass</variable>
      <variable>InternalEnergy</variable>
      <variable>PseudoViscosity</variable>
      <variable>Materiau</variable>
    </output>
    <output-frequency>1e-4</output-frequency>
    <format>
      <binary-file>true</binary-file>
    </format>
  </arcane-post-processing>
  
  <mesh>
    <meshgenerator>
    <cartesian>
       <nsd>1 1</nsd> 
       <origine>-.1 -.05 0.0</origine>
       <lx nx='10' prx='1.0'>1.</lx>
       <ly ny='1' pry='1.0'>.1</ly>
     </cartesian>
     </meshgenerator>
    <initialisation>
    </initialisation>
  </mesh>

  <arcane-checkpoint>
    <period>10</period>
    <!-- Mettre '0' si on souhaite ne pas faire de protections a la fin du calcul -->
    <do-dump-at-end>0</do-dump-at-end>
    <checkpoint-service name="ArcaneBasic2CheckpointWriter" />
  </arcane-checkpoint>

  <!-- Configuration du module hydrodynamique -->
  <mahyco>
  <material><name>ZG_mat</name></material>
  <material><name>ZD_mat</name></material>
  <environment>
    <name>ZG</name>
    <material>ZG_mat</material>
    <densite-initiale>1.</densite-initiale>
    <pression-initiale>1.</pression-initiale>
    <eos-model name="PerfectGas">
      <adiabatic-cst>1.4</adiabatic-cst>
      <specific-heat>2.4</specific-heat>
    </eos-model> 
  </environment>
  <environment>
    <name>ZD</name>
    <material>ZD_mat</material>
    <densite-initiale>0.125</densite-initiale>
    <pression-initiale>.1</pression-initiale>
    <eos-model name="PerfectGas">
      <adiabatic-cst>1.4</adiabatic-cst>
      <specific-heat>2.4</specific-heat>
    <!-- <eos-model name="StiffenedGas">
      <adiabatic-cst>1.4</adiabatic-cst>
      <specific-heat>2.4</specific-heat>
      <limit-tension>0.01</limit-tension> -->
    </eos-model> 
  </environment>
  
   <cas-model name="SOD">
   <cas-test>3</cas-test>
   </cas-model>
    <pseudo-centree>0</pseudo-centree>
    <with-projection>false</with-projection>
    <schema-csts>0</schema-csts>
     <deltat-init>0.00001</deltat-init>
     <deltat-min>0.00000001</deltat-min>
     <deltat-max>0.0001</deltat-max>
    <longueur-caracteristique>racine-cubique-volume</longueur-caracteristique>
    <!-- <final-time>1e-3</final-time> -->
    <final-time>1e-4</final-time>
    
    <boundary-condition>
      <surface>XMIN</surface>
      <type>Vx</type>
      <value>0.</value>
    </boundary-condition>
    <boundary-condition>
      <surface>XMAX</surface>
      <type>Vx</type>
      <value>0.</value>
    </boundary-condition>
    <boundary-condition>
      <surface>YMIN</surface>
      <type>Vy</type>
      <value>0.</value>
    </boundary-condition>
    <boundary-condition>
      <surface>YMAX</surface>
      <type>Vy</type>
      <value>0.</value>
    </boundary-condition>
    <boundary-condition>
      <surface>ZMIN</surface>
      <type>Vz</type>
      <value>0.</value>
    </boundary-condition>
    <boundary-condition>
      <surface>ZMAX</surface>
      <type>Vz</type>
      <value>0.</value>
    </boundary-condition>
  </mahyco>
  
  <!-- IPG -->
  <ipg>
    <particle-injector-type name="UserFileInputParticles">
      <filename>particles_init_data</filename>
    </particle-injector-type>
    <ipg-output name="VtkAscii">
      <variable>ParticleVelocity</variable>
      <variable>ParticleRadius</variable>
      <variable>ParticleTemperature</variable>
    </ipg-output>
    <spray-type name="SprayFin">
    </spray-type>
  </ipg>
</case>