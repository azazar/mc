PACKAGE_STRING = "/src/filemanager"

AM_CPPFLAGS = \
	$(GLIB_CFLAGS) \
	-I$(top_srcdir) \
	-I$(top_srcdir)/lib/vfs \
	-DTEST_SHARE_DIR=\"$(abs_srcdir)/../fixtures\" \
	@CHECK_CFLAGS@

LIBS = @CHECK_LIBS@ \
	$(top_builddir)/src/libinternal.la \
	$(top_builddir)/lib/libmc.la

MOCK_FILE_OUTPUT_FILES = $(abs_top_srcdir)/tests/src/fixtures/filemanager/file-types/file_output/*.tsv

if ENABLE_MCLIB
LIBS += $(GLIB_LIBS)
endif

TESTS = \
	cd_to \
	examine_cd \
	exec_get_export_variables_ext \
	ext__exec_make_shell_string \
	ext__regex_check_type \
	filegui_is_wildcarded \
	get_random_hint

check_PROGRAMS = $(TESTS)

cd_to_SOURCES = \
	cd_to.c

examine_cd_SOURCES = \
	examine_cd.c

exec_get_export_variables_ext_SOURCES = \
	exec_get_export_variables_ext.c

ext__exec_make_shell_string_SOURCES = \
	ext__exec_make_shell_string.c

ext__regex_check_type_SOURCES = \
	ext__regex_check_type.c

get_random_hint_SOURCES = \
	get_random_hint.c

filegui_is_wildcarded_SOURCES = \
	filegui_is_wildcarded.c

# Generate dynamic test rules for each TSV fixture file
define test_tsv_template
check-ext-mapping-mock-file-$(1): ext__regex_check_type
	@echo "Running extensions type test with $(1)"; \
	PATH="$(abs_top_srcdir)/tests/src/fixtures/filemanager/file-types:$$$$PATH" \
	MC_MOCK_FILE_OUTPUT="$(2)" \
	./ext__regex_check_type
endef

$(foreach tsv,$(MOCK_FILE_OUTPUT_FILES),$(eval $(call test_tsv_template,$(notdir $(tsv:.tsv=)),$(tsv))))

# Convenience target: run all mock-file tests
check-ext-mapping-mock-file: $(patsubst %.tsv,check-ext-mapping-mock-file-%,$(notdir $(MOCK_FILE_OUTPUT_FILES)))
	@echo "All extension mapping tests passed"

.PHONY: check-ext-mapping-mock-file $(patsubst %.tsv,check-ext-mapping-mock-file-%,$(notdir $(MOCK_FILE_OUTPUT_FILES)))
