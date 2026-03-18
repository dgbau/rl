# Changelog

## v0.1.0 (2026-03-18)

### Features
- enable OpenSpec by default, with smart fallback
- add rl release command with auto-changelog
- block --auto when dogfooding rl toolkit
- repo-agnosticism
- add music-theory template
- add creative-coding template
- add audio-plugin template for VST3/AU/CLAP development
- add swift-ios template
- add raspberry-pi template
- add python-ai-ml template
- add react, nextjs, nx core skills; fix audit bugs; expand webgpu

### Bug Fixes
- remove debug output leaking into .claude/skills/.gitignore
- reply to and resolve PR comments after review fixes

### Refactoring
- restructure skill taxonomy for LLM + human comprehension

### Documentation
- remove hardcoded ~/src paths from README and setup.sh
- replace hardcoded ~/src/rl with <your-path>/rl
- clarify tk + OpenSpec complementary roles

### Maintenance
- enable OpenSpec for rl dogfooding
- remove PII and hardcoded paths for OSS readiness
- add .gitignore

### Other
- external improvements
