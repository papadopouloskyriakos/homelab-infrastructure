# ========================================================================
# Node failure domains — topology.kubernetes.io/zone
# ========================================================================
# CANONICAL FILE — byte-identical in the NL, GR and NO repos. Every value
# is a var.* fed from this repo's terraform.tfvars; no site identifier
# appears here (see the Mirror contract in k8s/CLAUDE.md).
#
# WHY THIS EXISTS. Kubernetes spreads replicas across failure domains by
# itself — kube-scheduler's default topology spread, every chart that sets
# topologySpreadConstraints or a zone-keyed podAntiAffinity, CNPG's own
# placement — but only if the nodes CARRY a zone label. Unlabelled nodes
# are ONE zone as far as the scheduler is concerned, so a workload that
# reads as highly available is free to put every replica behind a single
# upstream, and nothing reports it.
#
# That is not hypothetical here: when these labels first went on, BOTH
# Postgres clusters at the NO site turned out to be running 2 of their 3
# replicas in the same domain. The label is what turned that from an
# invisible property into a query.
#
# HOW TO ADD A SITE. Put the map in that site's terraform.tfvars — node
# name -> zone name — and set node_zone_basis to the sentence that says
# what the boundary physically IS. An empty map creates nothing, which is
# what a site that has not surveyed its own topology carries.
#
# ⚠ A ZONE NAME IS A CLAIM ABOUT SHARED FATE, NOT A LOCATION. Two nodes
# belong in one zone when they die together: one rack, one PSU, one
# upstream, one hypervisor. Splitting nodes that in fact share a failure
# domain is WORSE than leaving them unzoned, because the scheduler then
# believes it has spread a workload that it has not, and the belief is
# what gets trusted in a design review. Only claim the boundary you can
# point at, and say which one it is in node_zone_basis.
#
# ⚠⚠ THE TWO RESOURCES BELOW MUST NEVER SHARE A field_manager. Both patch
# the SAME Node object, and a server-side apply declares the COMPLETE set
# of fields that manager owns: the second apply therefore REMOVES whatever
# the first one wrote. The first version of this file gave both the name
# "opentofu-node-zones" and the result was a silent, order-dependent
# split — `tofu apply` reported "12 added", state held all twelve, nothing
# was red, and four of the six nodes had no annotation because the label
# resource happened to run last on them. On the other two the ANNOTATION
# ran last, and their zone label survived only because a leftover
# kubectl-label ownership was still holding it; on a clean node those two
# would have lost the label outright. Distinct names, and leave them
# distinct.
# ========================================================================

resource "kubernetes_labels" "node_zone" {
  for_each = var.node_zones

  api_version = "v1"
  kind        = "Node"

  metadata {
    name = each.key
  }

  labels = {
    "topology.kubernetes.io/zone" = each.value
  }

  # force is not optional here. These labels are adopted rather than
  # created: a node that was labelled by hand carries somebody else's
  # server-side-apply field manager, and without force the apply fails on
  # the field conflict instead of taking ownership. The same applies to a
  # cloud controller or a kubelet --node-labels flag setting it at join.
  field_manager = "opentofu-node-zone-label"
  force         = true
}

# The zone label says WHICH domain a node is in. This says why the
# boundary is where it is, on the object an operator actually reads when
# they are deciding whether a spread constraint means anything.
resource "kubernetes_annotations" "node_zone_basis" {
  # A `for` expression rather than a conditional, so the type is map(string)
  # in both branches — `cond ? {} : var.node_zones` makes Terraform unify an
  # empty object with a map and the error it produces names neither.
  for_each = { for node, zone in var.node_zones : node => zone if var.node_zone_basis != "" }

  api_version = "v1"
  kind        = "Node"

  metadata {
    name = each.key
  }

  annotations = {
    "infra.example.net/zone-basis" = var.node_zone_basis
  }

  # KEPT at the old shared name on purpose, and it is not interchangeable
  # with the label's. This manager is the one that still owns the stray
  # `example.net/zone-basis` key the collision above left on some
  # nodes, and an apply from the owning manager that omits a field is the
  # ONLY thing that removes it. Renaming this would strand that key with an
  # owner nothing ever applies as again, and it would have to be deleted by
  # hand. The label resource took the new name instead.
  field_manager = "opentofu-node-zones"
  force         = true
}
