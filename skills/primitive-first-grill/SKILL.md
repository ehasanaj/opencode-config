---
name: primitive-first-grill
description: "Design and implement a specific software feature exactly with the user through a gated, bottom-up interview: settle exact models and types first, then logical surfaces and function interfaces from the lowest layer upward, then obtain final blueprint approval before coding. Use when the user asks for primitive-first grilling, wants an agent to implement a feature as they would, or requires exact approval of data shapes, layer boundaries, signatures, and helpers before implementation."
---

# Primitive-First Grill

Build shared understanding from the smallest primitives upward, then implement only the approved design.

## Rules

- Inspect the relevant codebase before asking design questions. Answer questions through code exploration whenever possible.
- Ask one question at a time and include a recommended answer with a brief reason.
- Resolve dependencies before dependents. Do not discuss a higher layer while a lower layer remains unsettled.
- Record each approved decision as the blueprint. Do not reopen it unless new evidence creates a conflict.
- Treat names, types, fields, signatures, visibility, and layer ownership as exact decisions, not rough sketches.
- Do not edit production code before the final blueprint approval.
- Do not invent an unapproved model, function, helper, abstraction, or layer during implementation.

## Workflow

### 1. Establish Scope

Inspect the feature request, repository structure, conventions, relevant models, call paths, tests, and documented standards. Summarize the feature boundary and identify uncertainties.

Ask for approval of the feature boundary before designing it. Keep unrelated refactors out of scope.

### 2. Settle Data Primitives

Identify every model, type, interface, enum, schema, DTO, event, and persisted shape that must be added or changed. If none are needed, explicitly propose and obtain approval for no model-layer changes.

Work through one primitive at a time. Specify its exact code-level shape, including every applicable detail:

- name and location
- kind and visibility
- fields or variants in declaration order
- field types, optionality, nullability, defaults, and mutability
- constraints, invariants, identity, and relationships
- serialization, validation, and persistence representation

Show a concise declaration or language-appropriate pseudocode when it removes ambiguity. Obtain explicit approval for each primitive, then obtain approval for the complete model layer.

### 3. Identify Logical Surfaces

Derive the feature's logical surfaces from the existing architecture rather than assuming a fixed layering scheme. Examples include repository, domain/service, application/use-case, resource/controller, adapter, and presentation surfaces.

Propose:

- each surface's responsibility and boundary
- its dependencies
- the bottom-up order in which to define and implement it

Obtain approval for the surfaces and their order before defining functions.

### 4. Settle Function Interfaces Bottom-Up

Start with the lowest approved surface and finish it before moving upward. Define every required public, internal, and helper function at interface level.

For each function, settle:

- exact name, owner, location, and visibility
- parameters in order, with exact types and defaults
- return type and result shape
- purpose and observable contract
- failure behavior and error type
- relevant side effects, transaction boundary, and authorization responsibility

Ask for explicit approval of each function, including helpers. Then obtain approval for the completed surface before moving to the next one.

Do not prescribe internal algorithms unless the user asks or correctness requires an algorithmic decision.

### 5. Approve the Blueprint

Present one consolidated implementation blueprint containing:

- feature scope and explicit non-goals
- exact model and type declarations
- logical surfaces in bottom-up order
- every function signature grouped by surface
- agreed contracts, failures, side effects, and unresolved assumptions
- files expected to be added or changed
- verification expectations

Ask for one final explicit approval. If the user changes anything, update the blueprint and ask again. Begin implementation only after an unambiguous approval.

### 6. Implement and Verify

Implement the approved blueprint from the lowest layer upward, following repository conventions and keeping changes limited to the agreed scope. Add or update focused tests and run the relevant quality checks.

If implementation reveals a need for any unapproved model change, signature, helper, surface, or behavior, stop before introducing it. Explain the discovery, recommend the smallest blueprint amendment, obtain approval, update the blueprint, and then continue.

Report the implemented changes, verification results, and any approved deviations from the original blueprint.
