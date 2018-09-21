build:
	nimble build

dev:
	nimble build --threads:on && ./smalte build --scope SCOPE\.* --scope NPM \
		test.conf.tmpl:test.conf \
		test.conf.tmpl:test2.conf \
		test.conf.tmpl:test3.conf \
		test.conf.tmpl:test4.conf \
		test.conf.tmpl:test5.conf

release:
	nim c -d:release --threads:on --opt:size src/smalte.nim

test:
	nim c --threads:on -r tests/test1.nim
