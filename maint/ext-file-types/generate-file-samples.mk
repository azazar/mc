REPO_ROOT := $(abspath ../..)
EXTENSIONS_INI_FILE ?= $(REPO_ROOT)/misc/mc.ext.ini
SECTIONS_WITH_TYPE = $(shell perl list-type-sections.pl $(EXTENSIONS_INI_FILE))

TEMP_DIR ?= /tmp
SAMPLE_FILES_DIR := $(REPO_ROOT)/tests/src/fixtures/filemanager/file-types/sample_files

APT_GET ?= sudo apt-get install -y

define ensure_command
	@command -v $(1) >/dev/null 2>&1 || $(APT_GET) $(2)
endef

C_FILE := $(TEMP_DIR)/test.c

SAMPLES := $(shell perl list-type-sections.pl $(EXTENSIONS_INI_FILE) | xargs -I{} echo "$(SAMPLE_FILES_DIR)/{}")

.PHONY: all prep clean check

all: check

check: prep $(SAMPLES)
	perl test-type-sections.pl $(EXTENSIONS_INI_FILE) $(SAMPLE_FILES_DIR)

prep: $(EXTENSIONS_INI_FILE)
	@mkdir -p "$(SAMPLE_FILES_DIR)"
	@echo 'int main() { return 0; }' > "$(C_FILE)"

$(SAMPLE_FILES_DIR)/3gp: | prep
	$(call ensure_command,ffmpeg,ffmpeg)
	ffmpeg -f lavfi -i testsrc=d=1 -c:v libx264 -f 3gp "$@"

$(SAMPLE_FILES_DIR)/Mach-O: | prep
	$(call ensure_command,clang,clang)
	clang -target x86_64-apple-darwin -c "$(C_FILE)" -o "$@"

$(SAMPLE_FILES_DIR)/Typescript: | prep
	# MC extestions file expects Java identified as Typescript. We will not follow that and create a simple Typescript file instead.
	printf 'interface Greeter {\n    greet(name: string): string;\n}\n\nconst greeter: Greeter = {\n    greet(name: string): string {\n        return `Hello, ${name}!`;\n    },\n};\n\nconsole.log(greeter.greet("World"));\n' > "$@"

$(SAMPLE_FILES_DIR)/bitmap: | prep
	$(call ensure_command,convert,imagemagick)
	convert -size 10x10 xc:white BMP3:"$@"

$(SAMPLE_FILES_DIR)/bzip: | prep
	echo 'QlowOX/////VbJW6AAAAAAA=' | base64 -d > "$@"

$(SAMPLE_FILES_DIR)/bzip2: | prep
	$(call ensure_command,bzip2,bzip2)
	date | bzip2 > "$@"

$(SAMPLE_FILES_DIR)/compress: | prep
	$(call ensure_command,compress,ncompress)
	date | compress -f -c > "$@"

$(SAMPLE_FILES_DIR)/elf: | prep
	$(call ensure_command,clang,clang)
	clang -target x86_64-unknown-linux-gnu "$(C_FILE)" -o "$@"

$(SAMPLE_FILES_DIR)/framemaker: | prep
	printf '<MIFFile 7.00>\n' > "$@"

$(SAMPLE_FILES_DIR)/gif: | prep
	$(call ensure_command,convert,imagemagick)
	convert rose: -resize 1x1 -depth 8 gif:"$@"

$(SAMPLE_FILES_DIR)/gzip: | prep
	$(call ensure_command,gzip,gzip)
	date | gzip -c > "$@"

$(SAMPLE_FILES_DIR)/info-by-type: | prep
	printf 'This is Info file sample.info, produced by makeinfo version 7.\n\nFile: sample.info,  Node: Top,  Next: ,  Prev: (dir),  Up: (dir)\n\nGenerated sample info document.\n' > "$@"

$(SAMPLE_FILES_DIR)/ipk-deb: | prep
	$(call ensure_command,dpkg-deb,dpkg)
	DEB_DIR=`mktemp -d`; mkdir -p "$$DEB_DIR/DEBIAN"; \
	printf 'Package: sample\nVersion: 1.0\nArchitecture: all\nMaintainer: none <none@none.none>\nDescription: Sample package\n' > "$$DEB_DIR/DEBIAN/control"; \
	dpkg-deb --build "$$DEB_DIR" "$@"; \
	$(RM) -r "$$DEB_DIR"

$(SAMPLE_FILES_DIR)/ipk-openwrt: | prep
	$(call ensure_command,wget,wget)
	wget 'https://downloads.openwrt.org/releases/23.05.3/packages/mips_24kc/packages/acme_4.0.0_all.ipk' -O "$@"

$(SAMPLE_FILES_DIR)/jar: Makefile | prep
	$(call ensure_command,java,default-jdk-headless)
	$(call ensure_command,javac,default-jdk-headless)
	$(call ensure_command,jar,default-jdk-headless)
	JAVA_BUILD_DIR="$(TEMP_DIR)/file-output-variants-java"; \
	JAVA_SOURCE_FILE="$$JAVA_BUILD_DIR/SampleJar.java"; \
	JAVA_CLASS_FILE="$$JAVA_BUILD_DIR/SampleJar.class"; \
	mkdir -p "$$JAVA_BUILD_DIR"; \
	printf '%s\n' \
		'public class SampleJar {' \
		'    public static void main(String[] args) {' \
		'        System.out.println("Hello, World!");' \
		'    }' \
		'}' > "$$JAVA_SOURCE_FILE"; \
	javac -d "$$JAVA_BUILD_DIR" "$$JAVA_SOURCE_FILE"; \
	jar --create --file "$@" --main-class SampleJar -C "$$JAVA_BUILD_DIR" "SampleJar.class"; \
	$(RM) -f "$$JAVA_SOURCE_FILE" "$$JAVA_CLASS_FILE"

$(SAMPLE_FILES_DIR)/jng: | prep
	printf '\213JNG\r\n\032\n' > "$@"

$(SAMPLE_FILES_DIR)/jpeg: | prep
	$(call ensure_command,ffmpeg,ffmpeg)
	ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=25 -vf "drawtext=text='JPEG Test':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2" -q:v 2 -frames:v 1 -update 1 -f image2 "$@"

$(SAMPLE_FILES_DIR)/lz: | prep
	$(call ensure_command,lzip,lzip)
	date | lzip -c > "$@"

$(SAMPLE_FILES_DIR)/lzma: | prep
	$(call ensure_command,lzma,xz-utils)
	date | lzma > "$@"

$(SAMPLE_FILES_DIR)/mailbox: | prep
	printf "From user@domain.com Sat Jan 1 00:00:00 2022\nSubject: Test Email\n\nThis is a test email message." > "$@"

$(SAMPLE_FILES_DIR)/man: | prep
	echo '.TH Title 1 "Date" "Source" "Manual" "Section"' > "$@"

$(SAMPLE_FILES_DIR)/mng: | prep
	$(call ensure_command,convert,imagemagick)
	convert xc:none -size 1x1 -depth 1 -type palette -colors 1 MNG:"$@"

$(SAMPLE_FILES_DIR)/msdoc-by-type: | prep
	$(call ensure_command,lowriter,libreoffice-writer)
	cd `mktemp -d`
	echo "# Test Document\n\nThis document is generated using LibreOffice Writer.\n\nThis is a sample paragraph to ensure the document has enough content to be substantial.\n\nAdditional lines are added to reach the required file size.\n\nWe are testing the LibreOffice Writer tool for creating Word documents." > "sample.md"
	lowriter --headless --convert-to doc *.md
	mv "sample.doc" "$@"
	$(RM) -f *.md

$(SAMPLE_FILES_DIR)/msxls-by-type: | prep
	$(call ensure_command,localc,libreoffice-calc)
	cd `mktemp -d`
	echo "A,B,C\n1,2,3\n4,5,6\n7,8,9" > "sample.csv"
	localc --headless --convert-to xls *.csv
	mv "sample.xls" "$@"
	$(RM) -f *.csv

$(SAMPLE_FILES_DIR)/mso-doc-1: | prep
	$(call ensure_command,lowriter,libreoffice-writer)
	cd `mktemp -d`
	echo "# Test Document\n\nThis document is generated using LibreOffice Writer.\n\nThis is a sample paragraph to ensure the document has enough content to be substantial.\n\nAdditional lines are added to reach the required file size.\n\nWe are testing the LibreOffice Writer tool for creating Word documents." > "sample.md"
	lowriter --headless --convert-to doc *.md
	mv "sample.doc" "$@"
	$(RM) -f *.md

$(SAMPLE_FILES_DIR)/mso-doc-2: | prep
	$(call ensure_command,pandoc,pandoc)
	printf '# Generated by pandoc\n\nThis is a simple OOXML document.\n' | pandoc -t docx -o "$@"

$(SAMPLE_FILES_DIR)/netpbm: | prep
	$(call ensure_command,pgmmake,netpbm)
	pgmmake 0.5 100 100 > "$@"

$(SAMPLE_FILES_DIR)/pgm: | prep
	printf 'P5\n1 1\n255\n\200' > "$@"

$(SAMPLE_FILES_DIR)/pdf: | prep
	$(call ensure_command,ps2pdf,ghostscript)
	(echo '%!PS'; echo '/Times-Roman findfont 12 scalefont setfont'; echo '72 720 moveto'; date '+(%c) show'; echo 'showpage') | ps2pdf - "$@"

$(SAMPLE_FILES_DIR)/png: | prep
	$(call ensure_command,convert,imagemagick)
	convert -size 100x100 xc:skyblue png:"$@"

$(SAMPLE_FILES_DIR)/ppm: | prep
	printf 'P6\n1 1\n255\n\200\200\200' > "$@"

$(SAMPLE_FILES_DIR)/rbm: | prep
	printf 'P4\n8 1\n\200' > "$@"

$(SAMPLE_FILES_DIR)/postscript: | prep
	(echo '%!PS'; echo '%Creator: MyPostScriptGenerator'; echo '%Pages: 1'; echo '%BoundingBox: (atend)'; echo '1 0.5 scale'; echo '100 100 moveto'; date '+(%c) show'; echo 'showpage'; yes 'showpage' | head -n 50; echo '%%EOF') > "$@"

$(SAMPLE_FILES_DIR)/sqlite3.db: | prep
	$(call ensure_command,sqlite3,sqlite3)
	sqlite3 "$@" 'CREATE TABLE test (id INTEGER PRIMARY KEY);'

$(SAMPLE_FILES_DIR)/tiff: | prep
	$(call ensure_command,convert,imagemagick)
	convert -size 100x100 xc:white "$@.tiff"
	mv "$@.tiff" "$@"

$(SAMPLE_FILES_DIR)/webm-by-type: | prep
	$(call ensure_command,ffmpeg,ffmpeg)
	ffmpeg -f lavfi -i testsrc=duration=5:size=1280x720:rate=30 -c:v libvpx-vp9 -b:v 1M -c:a libopus -f webm "$@"

$(SAMPLE_FILES_DIR)/xz: | prep
	$(call ensure_command,xz,xz-utils)
	date | xz > "$@"

$(SAMPLE_FILES_DIR)/lha: | prep
	# There is no widely available command-line tool for creating LHA files, so we will create a simple LHA file using a base64-encoded string that supposed to represent a valid LHA file.
	# It was originally downloaded from following URL: https://github.com/jca02266/lha/raw/refs/heads/master/tests/lha-test16-l0.lzh
	echo 'Kg0tbGg1LQAAAAAAAAAA8QtPMyAACG51bGxmaWxlAABVAGbdT0OkgfUBZAAA' | base64 -d > "$@"

$(SAMPLE_FILES_DIR)/troff.gz: | prep
	$(call ensure_command,gzip,gzip)
	printf '.TH SAMPLE 1\n.SH NAME\nsample\n' | gzip -c > "$@"

$(SAMPLE_FILES_DIR)/troff.bzip: | prep
	$(call ensure_command,bzip2,bzip2)
	printf '.TH SAMPLE 1\n.SH NAME\nsample\n' | bzip2 -c > "$@"

$(SAMPLE_FILES_DIR)/troff.bzip2: | prep
	$(call ensure_command,bzip2,bzip2)
	printf '.TH SAMPLE 1\n.SH NAME\nsample\n' | bzip2 -c > "$@"

$(SAMPLE_FILES_DIR)/zstd: | prep
	$(call ensure_command,zstd,zstd)
	date | zstd -o "$@"

$(SAMPLE_FILES_DIR)/zip-by-type: | prep
	$(call ensure_command,zip,zip)
	ZIP_INPUT_DIR="$(TEMP_DIR)/zip-by-type"; \
	mkdir -p "$$ZIP_INPUT_DIR"; \
	dd if=/dev/urandom of="$$ZIP_INPUT_DIR/data.bin" bs=256 count=1 status=none; \
	(cd "$$ZIP_INPUT_DIR" && zip -q -0 "$(notdir $@)" data.bin); \
	mv "$$ZIP_INPUT_DIR/$(notdir $@).zip" "$@"; \
	$(RM) -rf "$$ZIP_INPUT_DIR"

$(SAMPLE_FILES_DIR)/pak: | prep
	$(call ensure_command,arc,arc)
	$(call ensure_command,python3,python3)
	PAK_TMP_DIR="$(TEMP_DIR)/pak-archive"; \
	PAK_ARC="$(TEMP_DIR)/pakarc.arc"; \
	mkdir -p "$$PAK_TMP_DIR"; \
	: > "$$PAK_TMP_DIR/empty.txt"; \
	(cd "$$PAK_TMP_DIR" && arc a "$$PAK_ARC" empty.txt >/dev/null 2>&1); \
	python3 -c "from pathlib import Path; data = bytearray(Path('$$PAK_ARC').read_bytes()); data[1] = 0x0a; Path('$(SAMPLE_FILES_DIR)/pak').write_bytes(data)"; \
	$(RM) -rf "$$PAK_TMP_DIR" "$$PAK_ARC"

$(SAMPLE_FILES_DIR)/par2: | prep
	$(call ensure_command,par2,par2)
	PAR2_INPUT="$(SAMPLE_FILES_DIR)/par2-input.bin"; \
	printf 'Generated by par2\n' > "$$PAR2_INPUT"; \
	par2 create -q "$@" "$$PAR2_INPUT" >/dev/null 2>&1; \
	mv "$@.par2" "$@"; \
	$(RM) -f "$$PAR2_INPUT" "$@.vol"* 2>/dev/null || true

clean:
	$(RM) -f "$(C_FILE)"
	$(RM) -r "$(TEMP_DIR)/file-output-variants-java"
