/*
   src/filemanager - regex_check_type() function testing

   Copyright (C) 2026
   Free Software Foundation, Inc.

   Written by:
   Mikhail Yevchenko <spam@uo1.net>, 2026

   This file is part of the Midnight Commander.

   The Midnight Commander is free software: you can redistribute it
   and/or modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation, either version 3 of the License,
   or (at your option) any later version.

   The Midnight Commander is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#define TEST_SUITE_NAME "/src/filemanager"

#include "tests/mctest.h"

#include "lib/global.h"
#include "lib/mcconfig.h"
#include "lib/strutil.h"
#include "lib/vfs/path.h"

#include "src/vfs/local/local.h"

#ifdef USE_FILE_CMD
MC_TESTABLE gboolean regex_check_type (const vfs_path_t *filename_vpath, const char *ptr,
                                       gboolean case_insense, gboolean *have_type,
                                       GError **mcerror);

/* --------------------------------------------------------------------------------------------- */

static void
setup (void)
{
    str_init_strings (NULL);
    vfs_init ();
    vfs_init_localfs ();
    vfs_setup_work_dir ();
}

/* --------------------------------------------------------------------------------------------- */

static void
teardown (void)
{
    vfs_shut ();
    str_uninit_strings ();
}

/* --------------------------------------------------------------------------------------------- */

START_TEST (test_regex_check_type_sections)
{
    const char *srcdir_env;
    char *cwd;
    char *srcdir;
    char *ini_path;
    char *sample_dir;
    mc_config_t *mc_config;
    gchar **groups;
    gsize i;
    guint checked_sections = 0;

    cwd = g_get_current_dir ();
    srcdir_env = g_getenv ("srcdir");
    srcdir = g_strdup (srcdir_env != NULL ? srcdir_env : NULL);

    ini_path = g_build_filename (srcdir != NULL ? srcdir : cwd, "..", "..", "..", "misc",
                                 "mc.ext.ini", (char *) NULL);
    if (!g_file_test (ini_path, G_FILE_TEST_EXISTS))
    {
        g_free (ini_path);
        ini_path = g_build_filename (cwd, "misc", "mc.ext.ini", (char *) NULL);
    }
    else
    {
        char *canonical_ini_path;

        canonical_ini_path = g_canonicalize_filename (ini_path, NULL);
        g_free (ini_path);
        ini_path = canonical_ini_path;
    }

    sample_dir = g_build_filename (TEST_SHARE_DIR, "filemanager", "file-types", "sample_files",
                                   (char *) NULL);
    {
        char *canonical_sample_dir;

        canonical_sample_dir = g_canonicalize_filename (sample_dir, NULL);
        g_free (sample_dir);
        sample_dir = canonical_sample_dir;
    }

    ck_assert_msg (ini_path != NULL, "Failed to locate misc/mc.ext.ini from %s", cwd);
    ck_assert_msg (sample_dir != NULL, "Failed to locate file-type fixtures from %s", cwd);
    ck_assert_msg (g_file_test (ini_path, G_FILE_TEST_EXISTS), "Failed to locate misc/mc.ext.ini from %s",
                   cwd);
    ck_assert_msg (g_file_test (sample_dir, G_FILE_TEST_IS_DIR), "Failed to locate file-type fixtures at %s",
                   sample_dir);

    mc_config = mc_config_init (ini_path, TRUE);
    ck_assert_msg (mc_config != NULL, "Failed to open %s", ini_path);

    groups = mc_config_get_groups (mc_config, NULL);
    ck_assert_msg (groups != NULL, "Failed to get groups from %s", ini_path);

    for (i = 0; groups[i] != NULL; i++)
    {
        gboolean have_type;
        gboolean ignore_case;
        gboolean found;
        GError *mcerror = NULL;
        char *pattern;
        char *sample_path;
        vfs_path_t *sample_vpath;

        if (!mc_config_has_param (mc_config, groups[i], "Type"))
            continue;

        checked_sections++;
        pattern = mc_config_get_string_raw (mc_config, groups[i], "Type", NULL);
        ignore_case = mc_config_get_bool (mc_config, groups[i], "TypeIgnoreCase", FALSE);
        sample_path = g_build_filename (sample_dir, groups[i], (char *) NULL);

        ck_assert_msg (pattern != NULL, "Section [%s] has no Type pattern", groups[i]);
        ck_assert_msg (g_file_test (sample_path, G_FILE_TEST_EXISTS),
                       "Missing sample for Type section [%s]: %s (pattern: %s)", groups[i],
                       sample_path, pattern);

        sample_vpath = vfs_path_from_str (sample_path);
        have_type = FALSE;
        found = regex_check_type (sample_vpath, pattern, ignore_case, &have_type, &mcerror);

        ck_assert_msg (mcerror == NULL, "regex_check_type() failed for [%s] (pattern: %s): %s",
                       groups[i], pattern,
                       mcerror != NULL ? mcerror->message : "unknown error");
        ck_assert_msg (found, "Type pattern for [%s]: \"%s\" did not match sample %s",
                       groups[i], pattern, sample_path);

        g_clear_error (&mcerror);
        vfs_path_free (sample_vpath, TRUE);
        g_free (sample_path);
        g_free (pattern);
    }

    ck_assert_msg (checked_sections > 0, "No supported Type sections found in %s", ini_path);

    g_strfreev (groups);
    mc_config_deinit (mc_config);
    g_free (sample_dir);
    g_free (ini_path);
    g_free (srcdir);
    g_free (cwd);
}
END_TEST

/* --------------------------------------------------------------------------------------------- */

int
main (void)
{
    TCase *tc_core;

    tc_core = tcase_create ("Core");
    tcase_add_checked_fixture (tc_core, setup, teardown);

    // Add new tests here: ***************
    tcase_add_test (tc_core, test_regex_check_type_sections);
    // ***********************************

    return mctest_run_all (tc_core);
}

/* --------------------------------------------------------------------------------------------- */
#else
int
main (void)
{
    return 77;
}
#endif