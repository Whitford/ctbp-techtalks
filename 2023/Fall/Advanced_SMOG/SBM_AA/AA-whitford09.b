<?xml version="1.0"?>
<b>
  <!-- BONDS -->
  <bonds>
    <bond func="bond_harmonic(?,10000)">
      <bType>*</bType>
      <bType>*</bType>
    </bond>
  </bonds>
  <!-- ANGLES -->
  <angles>
    <angle func="angle_harmonic(?,80)">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </angle>
  </angles>
  <!-- DIHEDRALS -->
  <dihedrals>
    <!-- NUCLEIC DIHEDRALS -->
    <dihedral func="dihedral_cosine(?,1,1)+dihedral_cosine(?,0.5,3)" energyGroup="bb_n">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine(?,1,1)+dihedral_cosine(?,0.5,3)" energyGroup="sc_n">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_harmonic(?,40)" energyGroup="pr_n">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <!-- AMINO DIHEDRALS -->
    <dihedral func="dihedral_cosine(?,1,1)+dihedral_cosine(?,0.5,3)" energyGroup="bb_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_cosine(?,1,1)+dihedral_cosine(?,0.5,3)" energyGroup="sc_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_harmonic(?,40)" energyGroup="pr_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_harmonic(?,40)" energyGroup="pro_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_harmonic(?,10)" energyGroup="r_a">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <!-- LIGAND DIHEDRALS -->
    <dihedral func="dihedral_cosine(?,1,1)+dihedral_cosine(?,0.5,3)" energyGroup="bb_l">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
    <dihedral func="dihedral_harmonic(?,40)" energyGroup="r_l">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </dihedral>
  </dihedrals>
  <!-- IMPROPERS -->
  <impropers>
    <improper func="dihedral_harmonic(?,10)">
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
      <bType>*</bType>
    </improper>
  </impropers>
</b>
