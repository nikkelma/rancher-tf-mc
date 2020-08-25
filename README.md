# Rancher Master Class: Terraform

This is the repository containing example code from the Rancher Terraform master class.

## Requires Terraform version >= 0.13

Terraform 0.13 provides many great features that make provider and module management much easier,
so this release is required. Work is in-progress making all examples follow best practices for 0.13,
currently the only guarantee is that `terraform 0.13upgrade` was run on all examples. Please file
issues with `[0.13]` in the title if you find some missed module or example that doesn't play nice
with 0.13.

# Examples only - by default, not intended for direct use

> These are examples to show some useful patterns, and only if directly mentioned should they be
> considered for direct reuse.

I've learned a ton by refactoring Rancher's quickstart to fully use terraform, and then wanted to
learn more by giving a class on what I've learned (forcing me to learn even more). My experience is
in writing modules intended to fulfill a very direct purpose or with the intention of being reused.

Specicially, I have little experience in managing root modules - therefore, these are examples to
show some useful patterns, and only if directly mentioned should they be considered for direct
reuse.

## Please file issues!

If some example shows configuration that doesn't work or anything could be improved, please do file
issues on this repository. Happy to discuss these and integrate any improvements as my time allows.

## Documentation coming soon

I plan to condense this info into README files and Rancher blog posts, so keep an eye out for those
to give more context around this content.

