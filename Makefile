CC = gcc
LEX = flex
YACC = bison
CFLAGS = -Wall -Wextra -g -O2
LDFLAGS = -lm

# Target executable
TARGET = brolang_parser

# Source files
LEXER_SOURCE = brolang_lexer.l
PARSER_SOURCE = brolang_parser.y
LEXER_ICG_SOURCE = brolang_lexer_icg.l
PARSER_ICG_SOURCE = brolang_parser_icg.y
SUPPORTS = parser_utils.h
ICG_HEADER = icg.h
ICG_SOURCE = icg.c

# Generated files (Original parser)
LEXER_GEN = lex.yy.c
PARSER_GEN_H = brolang_parser.tab.h
PARSER_GEN_C = brolang_parser.tab.c

# Generated files (ICG parser)
LEXER_ICG_GEN = lex_icg.yy.c
PARSER_ICG_GEN_H = brolang_parser_icg.tab.h
PARSER_ICG_GEN_C = brolang_parser_icg.tab.c

# Object files (Original parser)
LEXER_OBJ = lex.yy.o
PARSER_OBJ = brolang_parser.tab.o

# Object files (ICG parser)
LEXER_ICG_OBJ = lex_icg.yy.o
PARSER_ICG_OBJ = brolang_parser_icg.tab.o
ICG_OBJ = icg.o

.PHONY: all clean test part3 part4 part3-pretty part3-graphs icg icg-test

all: $(TARGET) brolang_parser_icg

$(TARGET): $(LEXER_OBJ) $(PARSER_OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEXER_OBJ) $(PARSER_OBJ) $(LDFLAGS)

$(PARSER_GEN_C) $(PARSER_GEN_H): $(PARSER_SOURCE) $(SUPPORTS)
	$(YACC) -d -o $(PARSER_GEN_C) $(PARSER_SOURCE)

$(LEXER_GEN): $(LEXER_SOURCE) $(PARSER_GEN_H)
	$(LEX) -o $(LEXER_GEN) $(LEXER_SOURCE)

$(LEXER_OBJ): $(LEXER_GEN)
	$(CC) $(CFLAGS) -c -o $(LEXER_OBJ) $(LEXER_GEN)

$(PARSER_OBJ): $(PARSER_GEN_C)
	$(CC) $(CFLAGS) -c -o $(PARSER_OBJ) $(PARSER_GEN_C)

# ICG Parser rules
brolang_parser_icg: $(LEXER_ICG_OBJ) $(PARSER_ICG_OBJ) $(ICG_OBJ)
	$(CC) $(CFLAGS) -o brolang_parser_icg $(LEXER_ICG_OBJ) $(PARSER_ICG_OBJ) $(ICG_OBJ) $(LDFLAGS)

$(PARSER_ICG_GEN_C) $(PARSER_ICG_GEN_H): $(PARSER_ICG_SOURCE) $(ICG_HEADER)
	$(YACC) -d -o $(PARSER_ICG_GEN_C) $(PARSER_ICG_SOURCE)

$(LEXER_ICG_GEN): $(LEXER_ICG_SOURCE) $(PARSER_ICG_GEN_H)
	$(LEX) -o $(LEXER_ICG_GEN) $(LEXER_ICG_SOURCE)

$(LEXER_ICG_OBJ): $(LEXER_ICG_GEN)
	$(CC) $(CFLAGS) -c -o $(LEXER_ICG_OBJ) $(LEXER_ICG_GEN)

$(PARSER_ICG_OBJ): $(PARSER_ICG_GEN_C)
	$(CC) $(CFLAGS) -c -o $(PARSER_ICG_OBJ) $(PARSER_ICG_GEN_C)

$(ICG_OBJ): $(ICG_SOURCE) $(ICG_HEADER)
	$(CC) $(CFLAGS) -c -o $(ICG_OBJ) $(ICG_SOURCE)

test: $(TARGET)
	@echo "Testing with valid test cases:"
	@for testfile in testcases/valid/*.bro; do \
		echo "\n--- Testing: $$testfile ---"; \
		./$(TARGET) "$$testfile"; \
	done
	@echo "\n\nTesting with invalid test cases:"
	@for testfile in testcases/invalid/*.bro; do \
		echo "\n--- Testing (expected error): $$testfile ---"; \
		./$(TARGET) "$$testfile" || true; \
	done

part3: $(TARGET)
	@outfile="PART3_REVERSE_DERIVATION_TREES.txt"; \
	echo "CS327 - Part 3 Reverse Derivation Trees (All Valid Testcases)" > "$$outfile"; \
	echo "Generated on: $$(date '+%Y-%m-%d %H:%M:%S')" >> "$$outfile"; \
	echo "" >> "$$outfile"; \
	for testfile in testcases/valid/*.bro; do \
		echo "==================================================" >> "$$outfile"; \
		echo "Testcase: $$testfile" >> "$$outfile"; \
		echo "==================================================" >> "$$outfile"; \
		./$(TARGET) "$$testfile" | awk '/PART 3: REVERSE DERIVATION TREE/{flag=1} /PART 4: LALR\(1\) PARSING TABLE OUTPUT/{flag=0} flag' >> "$$outfile"; \
		echo "" >> "$$outfile"; \
	done; \
	echo "Part 3 report generated: $$outfile"

part3-pretty: $(TARGET)
	@python3 generate_part3_pretty.py
	@echo "Pretty Part 3 report generated: PART3_DERIVATION_TREE_PRETTY.md"

part3-graphs: $(TARGET)
	@python3 generate_part3_pretty.py
	@if command -v dot >/dev/null 2>&1; then \
		echo "Graph files generated (DOT + PNG): part3_graphs/"; \
	else \
		echo "Graph files generated (DOT only): part3_graphs/"; \
		echo "Install Graphviz to enable PNG export: sudo apt-get install graphviz"; \
	fi

part4: $(TARGET) $(PARSER_GEN_C)
	@python3 generate_parsing_table.py; \
	awk '/^## Section 1: ACTION Table/{flag=1} /^## Section 3: State Details/{flag=0} flag' PART4_LALR1_PARSING_TABLE.md > PART4_ACTION_GOTO_TABLE.txt; \
	echo "Part 4 report generated: PART4_ACTION_GOTO_TABLE.txt"

icg: brolang_parser_icg
	@echo "ICG Parser built successfully"

icg-test: icg
	@echo "Testing ICG with valid test cases:"
	@for testfile in testcases/valid/*.bro; do \
		echo "\n--- Testing: $$testfile ---"; \
		./brolang_parser_icg "$$testfile"; \
	done

clean:
	rm -f $(LEXER_GEN) $(LEXER_OBJ) $(PARSER_GEN_C) $(PARSER_GEN_H) $(PARSER_OBJ) $(TARGET) *.o
	rm -f $(LEXER_ICG_GEN) $(LEXER_ICG_OBJ) $(PARSER_ICG_GEN_C) $(PARSER_ICG_GEN_H) $(PARSER_ICG_OBJ) brolang_parser_icg $(ICG_OBJ)

.PHONY: $(PARSER_GEN_H)
