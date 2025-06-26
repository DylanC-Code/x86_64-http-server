# ============================================================================== #
#                                 CONFIGURATION                                  #
# ============================================================================== #

# 📛 Program name
NAME := x86_64-http-server

# 📂 Directories
SRCS_DIR := srcs/
BUILD_DIR := build/

# 📦 Assembler & Flags
AS := as
LD := ld
FLAGS =

# 📁 Sources & Objets
SRCS :=	$(addprefix srcs/, \
		main.s \
		utils.s \
)
OBJS := $(patsubst %.s, $(BUILD_DIR)%.o, $(SRCS))

# 🛠 Utilitaires
RM := rm -rf


# ============================================================================== #
#                               RULES - BUILD FLOW                               #
# ============================================================================== #

all: $(BUILD_DIR) $(NAME)

$(NAME): $(OBJS)
	$(LD) -o $(NAME) $(OBJS)

# 🔨 Assembling of .s to .o
$(BUILD_DIR)%.o: %.s
	mkdir -p $(dir $@)
	$(AS) $< -o $@


# ============================================================================== #
#                            DIRECTORY & LIBRARY SETUP                           #
# ============================================================================== #

# 📁 Création du dossier de build
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


# ============================================================================== #
#                                   CLEAN RULES                                  #
# ============================================================================== #

clean:
	$(RM) $(BUILD_DIR)

fclean: clean
	$(RM) $(NAME)

re: fclean all


# ============================================================================== #
#                                  PHONY & DEPS                                  #
# ============================================================================== #

# 📌 Phony targets
.PHONY: all clean fclean re
