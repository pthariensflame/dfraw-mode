;;; dfraw-mode.el --- Dwarf Fortress "raw" file major mode.
;;; Author: Alexander Altman <alexanderaltman@me.com>
;;; Version: 0.0.2
;;; Homepage: https://github.com/pthariensflame/dfraw-mode
;;; Keywords: languages

;;; Commentary:
;;; A major mode for editing Dwarf Fortress's "raw" files, which are often
;;; used for modding and which specify various things not built in to the
;;; game.

;;; Code:
(defgroup dfraw nil
  "Customization group for dfraw-mode."
  :group 'languages
  :tag "DFRaw"
  :prefix "dfraw-")

(defcustom dfraw-header-face
  font-lock-preprocessor-face
  "The font-lock face used for the file header."
  :tag "Header Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-exocomment-face
  font-lock-comment-face
  "The font-lock face used for \"exocomments\"."
  :tag "Exocomment Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-bracket-face
  font-lock-keyword-face
  "The font-lock face used for square brackets."
  :tag "Bracket Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-colon-face
  dfraw-bracket-face
  "The font-lock face used for colons."
  :tag "Colon Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-token-face
  font-lock-builtin-face
  "The font-lock face used for general tokens."
  :tag "Token Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-object-face
  dfraw-token-face
  "The font-lock face used for the OBJECT token."
  :tag "Object Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-string-face
  font-lock-string-face
  "The font-lock face used for string parameters."
  :tag "String Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-file-path-face
  dfraw-string-face
  "The font-lock face used for file path parameters."
  :tag "File Path Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-unknown-face
  dfraw-string-face
  "The font-lock face used for otherwise unidentified parameters."
  :tag "Unknown Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-value-face
  font-lock-constant-face
  "The font-lock face used for value parameters."
  :tag "Value Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-objecttype-face
  font-lock-type-face
  "The font-lock face used for type parameters."
  :tag "Object-Type Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-typetoken-face
  dfraw-token-face
  "The font-lock face used for type tokens."
  :tag "Type-Token Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-tagtoken-face
  dfraw-token-face
  "The font-lock face used for nullary tokens that act like tags or flags."
  :tag "Tag-Token Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-exactstring-face
  font-lock-builtin-face
  "The font-lock face used for string-like exact parameters."
  :tag "Exact-String Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-exactvalue-face
  font-lock-builtin-face
  "The font-lock face used for value-like exact parameters."
  :tag "Exact-Value Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-objectidentifier-face
  font-lock-function-name-face
  "The font-lock face used for object identifier parameters."
  :tag "Object-Identifier Face"
  :type 'face
  :group 'dfraw)

(defcustom dfraw-identifier-face
  font-lock-variable-name-face
  "The font-lock face used for general identifier parameters."
  :tag "Identifier Face"
  :type 'face
  :group 'dfraw)

(defconst dfraw-font-lock-exocomment-header
  '(("\\`[^[:space:]]+$" (0 dfraw-header-face t))
    ("[^][]+" (0 dfraw-exocomment-face keep)))
  "Font-lock matchers for \"exocomments\" and the file header in Dwarf Fortress \"raw\" files.")

(defconst dfraw-font-lock-basic
  '(("\\(\\[\\)\\([A-Z0-9_]+\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     ("\\(:\\)\\([^][:]*\\)"
      (save-excursion
	(if (re-search-forward "\\]" (line-end-position) t)
            (point)
          nil))
      nil
      (1 dfraw-colon-face t)
      (2 dfraw-unknown-face t)))
    ("\\]" (0 dfraw-bracket-face t)))
  "Basic font-lock matchers for Dwarf Fortress \"raw\" files.")

(defconst dfraw-font-lock-token-specific
  `(

    ;;; top level tokens
    
    ;; OBJECT token
    (,(concat
       "\\(\\[\\)\\(OBJECT\\)\\(:\\)\\("
       (regexp-opt
	'("BODY"
	  "BODY_DETAIL_PLAN"
	  "BUILDING"
	  "CREATURE"
	  "CREATURE_VARIATION"
	  "DESCRIPTOR_COLOR"
	  "DESCRIPTOR_PATTERN"
	  "DESCRIPTOR_SHAPE"
	  "ENTITY"
	  "GRAPHICS"
	  "INTERACTION"
	  "INORGANIC"
	  "ITEM"
	  "LANGUAGE"
	  "MATERIAL_TEMPLATE"
	  "PLANT"
	  "REACTION"
	  "TISSUE_TEMPLATE"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-object-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-objecttype-face t)
     (5 dfraw-bracket-face t))
    
    ;; type tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("BODY"
	  "BODY_DETAIL_PLAN"
	  "BUILDING"
	  "CREATURE"
	  "CREATURE_VARIATION"
	  "COLOR"
	  "COLOR_PATTERN"
	  "SHAPE"
	  "ENTITY"
	  "GRAPHICS"
	  "INTERACTION"
	  "INORGANIC"
	  "ITEM_AMMO"
	  "ITEM_ARMOR"
	  "ITEM_FOOD"
	  "ITEM_GLOVES"
	  "ITEM_HELM"
	  "ITEM_INSTRUMENT"
	  "ITEM_PANTS"
	  "ITEM_SHIELD"
	  "ITEM_SHOES"
	  "ITEM_SIEGEAMMO"
	  "ITEM_TOOL"
	  "ITEM_TOY"
	  "ITEM_TRAPCOMP"
	  "ITEM_WEAPON"
	  "SYMBOL"
	  "WORD"
	  "TRANSLATION"
	  "MATERIAL_TEMPLATE"
	  "PLANT"
	  "REACTION"
	  "TISSUE_TEMPLATE"))
       "\\)\\(:\\)\\(\\(?:[A-Z0-9_,\\-]\\| \\)+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-typetoken-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-objectidentifier-face t)
     (5 dfraw-bracket-face t))

    ;;; world generation tokens
    
    ;; WORLD_GEN token
    ("\\(\\[\\)\\(WORLD_GEN\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-bracket-face t))
    
    ;; TITLE token
    ("\\(\\[\\)\\(TITLE\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-string-face t)
     (5 dfraw-bracket-face t))
    
    ;; DIM token
    ("\\(\\[\\)\\(DIM\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-bracket-face t))
    
    ;; EMBARK_POINTS token
    ("\\(\\[\\)\\(EMBARK_POINTS\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; END_YEAR token
    ("\\(\\[\\)\\(END_YEAR\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; BEAST_END_YEAR token
    ("\\(\\[\\)\\(BEAST_END_YEAR\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\(-1\\|[0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-bracket-face t))
    
    ;; REVEAL_ALL_HISTORY token
    ("\\(\\[\\)\\(REVEAL_ALL_HISTORY\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; CULL_HISTORICAL_FIGURES token
    ("\\(\\[\\)\\(CULL_HISTORICAL_FIGURES\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; terrain tokens
    (,(concat "\\(\\[\\)\\("
	      (regexp-opt
	       '("ELEVATION"
		 "RAINFALL"
		 "TEMPERATURE"
		 "DRAINAGE"
		 "VOLCANISM"
		 "SAVAGERY"))
	      "\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-colon-face t)
     (10 dfraw-value-face t)
     (11 dfraw-bracket-face t))
    
    ;; mesh tokens
    (,(concat "\\(\\[\\)\\("
	      (regexp-opt
	       '("ELEVATION_FREQUENCY"
		 "RAIN_FREQUENCY"
		 "DRAINAGE_FREQUENCY"
		 "TEMPERATURE_FREQUENCY"
		 "SAVAGERY_FREQUENCY"
		 "VOLCANISM_FREQUENCY"))
	      "\\)\\(:\\)\\(1\\|2\\|3\\|4\\|5\\|6\\|\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-colon-face t)
     (10 dfraw-value-face t)
     (11 dfraw-colon-face t)
     (12 dfraw-value-face t)
     (13 dfraw-colon-face t)
     (14 dfraw-value-face t)
     (15 dfraw-bracket-face t))

    ;; POLE token
    (,(concat
       "\\(\\[\\)\\(POLE\\)\\(:\\)\\("
       (regexp-opt
	'("NONE"
	  "NORTH_OR_SOUTH"
	  "NORTH_AND_OR_SOUTH"
	  "NORTH"
	  "SOUTH"
	  "NORTH_AND_SOUTH"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-bracket-face t))
    
    ;; MINERAL_SCARCITY token
    ("\\(\\[\\)\\(MINERAL_SCARCITY\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; *MEGABEAST_CAP tokens
    ("\\(\\[\\)\\(\\(?:SEMI\\)?MEGABEAST_CAP\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; *_NUMBER tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("TITAN_NUMBER"
	  "DEMON_NUMBER"
	  "NIGHT_TROLL_NUMBER"
	  "BOGEYMAN_NUMBER"
	  "VAMPIRE_NUMBER"
	  "WEREBEAST_NUMBER"
	  "SECRET_NUMBER"
	  "REGIONAL_INTERACTION_NUMBER"
	  "DISTURBANCE_INTERACTION_NUMBER"
	  "EVIL_CLOUD_NUMBER"
	  "EVIL_RAIN_NUMBER"
	  "TOTAL_CIV_NUMBER"))
       "\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; TITAN_ATTACK_TRIGGER token
    ("\\(\\[\\)\\(TITAN_ATTACK_TRIGGER\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-bracket-face t))
    
    ;; GOOD_SQ_COUNTS and EVIL_SQ_COUNTS tokens
    ("\\(\\[\\)\\(?:\\(GOOD\\|EVIL\\)_SQ_COUNTS\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-bracket-face t))
    
    ;; GENERATE_DIVINE_MATERIALS token
    ("\\(\\[\\)\\(GENERATE_DIVINE_MATERIALS\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; *_MIN, *_MAX, *_MIN_SIZE, and *_MAX_SIZE tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("PEAK_NUMBER_MIN"
	  "PARTIAL_OCEAN_EDGE_MIN"
	  "COMPLETE_OCEAN_EDGE_MIN"
	  "VOLCANO_MIN"
	  "CAVERN_LAYER_OPENNESS_MIN"
	  "CAVERN_LAYER_OPENNESS_MAX"
	  "CAVERN_LAYER_PASSAGE_DENSITY_MIN"
	  "CAVERN_LAYER_PASSAGE_DENSITY_MAX"
	  "CAVERN_LAYER_WATER_MIN"
	  "CAVERN_LAYER_WATER_MAX"
	  "CAVE_MIN_SIZE"
	  "CAVE_MAX_SIZE"
	  "MOUNTAIN_CAVE_MIN"
	  "NON_MOUNTAIN_CAVE_MIN"
	  "SUBREGION_MAX"))
       "\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; REGION_COUNTS token
    (,(concat
       "\\(\\[\\)\\(REGION_COUNTS\\)\\(:\\)\\("
       (regexp-opt
	'("SWAMP"
	  "DESERT"
	  "FOREST"
	  "MOUNTAINS"
	  "OCEAN"
	  "GLACIER"
	  "TUNDRA"
	  "GRASSLAND"
	  "HILLS"))
       "\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-colon-face t)
     (10 dfraw-value-face t)
     (11 dfraw-bracket-face t))
    
    ;; EROSION_CYCLE_COUNT token
    ("\\(\\[\\)\\(EROSION_CYCLE_COUNT\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; RIVER_MINS token
    ("\\(\\[\\)\\(RIVER_MINS\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-bracket-face t))
    
    ;; CAVERN_LAYER_COUNT token
    ("\\(\\[\\)\\(CAVERN_LAYER_COUNT\\)\\(:\\)\\(0\\|1\\|2\\|3\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; PERIODICALLY_ERODE_EXTREMES token
    ("\\(\\[\\)\\(PERIODICALLY_ERODE_EXTREMES\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; OROGRAPHIC_PRECIPITATION token
    ("\\(\\[\\)\\(OROGRAPHIC_PRECIPITATION\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; HAVE_BOTTOM_LAYER_* tokens
    ("\\(\\[\\)\\(HAVE_BOTTOM_LAYER_\\(?:1\\|2\\)\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; depth tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("LEVELS_ABOVE_GROUND"
	  "LEVELS_ABOVE_LAYER_1"
	  "LEVELS_ABOVE_LAYER_2"
	  "LEVELS_ABOVE_LAYER_3"
	  "LEVELS_ABOVE_LAYER_4"
	  "LEVELS_ABOVE_LAYER_5"
	  "LEVELS_AT_BOTTOM"))
       "\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; ALL_CAVES_VISIBLE token
    ("\\(\\[\\)\\(ALL_CAVES_VISIBLE\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; SHOW_EMBARK_TUNNEL token
    ("\\(\\[\\)\\(SHOW_EMBARK_TUNNEL\\)\\(:\\)\\(0\\|1\\|2\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; PLAYABLE_CIVILIZATION_REQUIRED token
    ("\\(\\[\\)\\(PLAYABLE_CIVILIZATION_REQUIRED\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; TOTAL_CIV_POPULATION token
    ("\\(\\[\\)\\(TOTAL_CIV_POPULATION\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; SITE_CAP token
    ("\\(\\[\\)\\(SITE_CAP\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; REVEAL_ALL_HISTORY token
    ("\\(\\[\\)\\(REVEAL_ALL_HISTORY\\)\\(:\\)\\(0\\|1\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; *_RANGES tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("ELEVATION_RANGES"
	  "RAIN_RANGES"
	  "DRAINAGE_RANGES"
	  "SAVAGERY_RANGES"
	  "VOLCANISM_RANGES"))
       "\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-bracket-face t))
    
    ;;; AMMO subtokens
    
    ;; NAME token
    ("\\(\\[\\)\\(NAME\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-string-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-string-face t)
     (7 dfraw-bracket-face t))
    
    ;; CLASS token
    ("\\(\\[\\)\\(CLASS\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-identifier-face t)
     (5 dfraw-bracket-face t))
    
    ;; SIZE and WEIGHT tokens
    ("\\(\\[\\)\\(SIZE\\|WEIGHT\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; ATTACK token
    ("\\(\\[\\)\\(ATTACK\\)\\(:\\)\\(BLUNT\\|EDGE\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-token-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-colon-face t)
     (10 dfraw-string-face t)
     (11 dfraw-colon-face t)
     (12 dfraw-string-face t)
     (13 dfraw-colon-face t)
     (14 dfraw-string-face t)
     (15 dfraw-colon-face t)
     (16 dfraw-value-face t)
     (17 dfraw-bracket-face t))
    
    ;; ATTACK_PREPARE_AND_RECOVER token
    ("\\(\\[\\)\\(ATTACK_PREPARE_AND_RECOVER\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-bracket-face t))

    ;;; BODY_DETAIL_PLAN subtokens

    ;; ADD_* tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("ADD_MATERIAL"
	  "ADD_TISSUE"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-identifier-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-identifier-face t)
     (7 dfraw-bracket-face t))

    ;; TODO: the following needs more work
    
    ;; ;; BP_LAYERS* tokens
    ;; (,(concat
    ;;    "\\(\\[\\)\\("
    ;;    (regexp-opt
    ;; 	'("BP_LAYERS"
    ;; 	  "BP_LAYERS_OVER"
    ;; 	  "BP_LAYERS_UNDER"))
    ;;    "\\)")
    ;;  (1 dfraw-bracket-face t)
    ;;  (2 dfraw-token-face t)
    ;;  (,(concat
    ;; 	"\\(:\\)\\("
    ;; 	(regexp-opt
    ;; 	 '("BY_CATEGORY"
    ;; 	   "BY_TYPE"
    ;; 	   "BY_TOKEN"))
    ;; 	"\\)\\(:\\)\\([A-Z0-9_]+\\)")
    ;;   (save-excursion
    ;; 	(if (re-search-forward "\\]" (line-end-position) nil)
    ;;         (point)
    ;;       nil))
    ;;   nil
    ;;   (1 dfraw-colon-face t)
    ;;   (2 dfraw-exactstring-face t)
    ;;   (3 dfraw-colon-face t)
    ;;   (4 dfraw-identifier-face t)
    ;;   (,(concat
    ;; 	 "\\(:\\)\\("
    ;; 	 (regexp-opt
    ;; 	  '("FRONT"
    ;; 	    "BACK"
    ;; 	    "LEFT"
    ;; 	    "RIGHT"
    ;; 	    "TOP"
    ;; 	    "BOTTOM"
    ;; 	    "SIDES"))
    ;; 	 "\\)")
    ;;    (save-excursion
    ;; 	 (if (re-search-forward "\\]" (line-end-position) nil)
    ;; 	     (point)
    ;; 	   nil))
    ;;    nil
    ;;    (1 dfraw-colon-face t)
    ;;    (2 dfraw-exactstring-face t))
    ;;   (,(concat
    ;; 	 "\\(:\\)\\("
    ;; 	 (regexp-opt
    ;; 	  '("AROUND"
    ;; 	    "SURROUNDED_BY"
    ;; 	    "ABOVE"
    ;; 	    "BELOW"
    ;; 	    "IN_FRONT"
    ;; 	    "BEHIND"
    ;; 	    "CLEANS"
    ;; 	    "CLEANED_BY"))
    ;; 	 "\\)\\(:\\)\\("
    ;; 	 (regexp-opt
    ;; 	  '("BY_CATEGORY"
    ;; 	   "BY_TYPE"
    ;; 	   "BY_TOKEN"))
    ;; 	 "\\)\\(:\\)\\([A-Z0-9_]+\\)")
    ;;    (save-excursion
    ;; 	 (if (re-search-forward "\\]" (line-end-position) nil)
    ;; 	     (point)
    ;; 	   nil))
    ;;    nil
    ;;    (1 dfraw-colon-face t)
    ;;    (2 dfraw-exactstring-face t)
    ;;    (3 dfraw-colon-face t)
    ;;    (4 dfraw-exactstring-face t)
    ;;    (5 dfraw-colon-face t)
    ;;    (6 dfraw-identifier-face t)))) ; closing bracket handled implicitly

    ;; BP_POSITION token
    (,(concat
       "\\(\\[\\)\\(BP_POSITION\\)\\(:\\)\\("
       (regexp-opt
	'("BY_CATEGORY"
	  "BY_TYPE"
	  "BY_TOKEN"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\("
       (regexp-opt
	'("FRONT"
	  "BACK"
	  "LEFT"
	  "RIGHT"
	  "TOP"
	  "BOTTOM"
	  "SIDES"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-identifier-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-exactstring-face t)
     (9 dfraw-bracket-face t))
    
    ;; BP_RELATION token
    (,(concat
       "\\(\\[\\)\\(BP_RELATION\\)\\(:\\)\\("
       (regexp-opt
	'("BY_CATEGORY"
	  "BY_TYPE"
	  "BY_TOKEN"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\("
       (regexp-opt
	'("AROUND"
	  "SURROUNDED_BY"
	  "ABOVE"
	  "BELOW"
	  "IN_FRONT"
	  "BEHIND"
	  "CLEANS"
	  "CLEANED_BY"))
       "\\)\\(:\\)\\("
       (regexp-opt
	'("BY_CATEGORY"
	  "BY_TYPE"
	  "BY_TOKEN"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-identifier-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-exactstring-face t)
     (9 dfraw-colon-face t)
     (10 dfraw-exactstring-face t)
     (11 dfraw-colon-face t)
     (12 dfraw-identifier-face t)
     (13 dfraw-colon-face t)
     (14 dfraw-value-face t)
     (15 dfraw-bracket-face t))

    ;; BP_RELSIZE token
    (,(concat
       "\\(\\[\\)\\(BP_RELSIZE\\)\\(:\\)\\("
       (regexp-opt
	'("BY_CATEGORY"
	  "BY_TYPE"
	  "BY_TOKEN"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-identifier-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-value-face t)
     (9 dfraw-bracket-face t))

    ;;; BODY subtokens
    
    ;; nullary tag tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("APERTURE"
	  "BREATHE"
	  "CIRCULATION"
	  "CONNECTOR"
	  "DIGIT"
	  "EMBEDDED"
	  "FLIER"
	  "GRASP"
	  "GUTS"
	  "HEAD"
	  "HEAR"
	  "INTERNAL"
	  "JOINT"
	  "LIMB"
	  "LOWERBODY"
	  "LEFT"
	  "MOUTH"
	  "NERVOUS"
	  "PREVENTS_PARENT_COLLAPSE"
	  "RIGHT"
	  "SKELETON"
	  "STANCE"
	  "SIGHT"
	  "SMELL"
	  "SMALL"
	  "SOCKET"
	  "THROAT"
	  "THOUGHT"
	  "TOTEMABLE"
	  "UPPERBODY"
	  "UNDER_PRESSURE"
	  "VERMIN_BUTCHER_ITEM"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-tagtoken-face t)
     (3 dfraw-bracket-face t))
    
    ;; BP token
    ("\\(\\[\\)\\(BP\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-identifier-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-string-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-string-face t)
     (9 dfraw-bracket-face t))
    
    ;; CATEGORY, CON, and CON_CAT tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("CATEGORY"
	  "CON"
	  "CON_CAT"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-identifier-face t)
     (5 dfraw-bracket-face t))
    
    ;; CONTYPE token
    (,(concat
       "\\(\\[\\)\\(CONTYPE\\)\\(:\\)\\("
       (regexp-opt
	'("UPPERBODY"
	  "LOWERBODY"
	  "HEAD"
	  "GRASP"
	  "STANCE"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-bracket-face t))
    
    ;; DEFAULT_RELSIZE token
    ("\\(\\[\\)\\(DEFAULT_RELSIZE\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; INDIVIDUAL_NAME token
    ("\\(\\[\\)\\(INDIVIDUAL_NAME\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-string-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-string-face t)
     (5 dfraw-bracket-face t))
    
    ;; NUMBER token
    ("\\(\\[\\)\\(NUMBER\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; BODYGLOSS token
    ("\\(\\[\\)\\(BODYGLOSS\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-identifier-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-string-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-string-face t)
     (9 dfraw-colon-face t)
     (10 dfraw-string-face t)
     (11 dfraw-colon-face t)
     (12 dfraw-string-face t)
     (13 dfraw-bracket-face t))

    ;;; ARMOR subtokens

    ;; NAME token is already covered by AMMO
    
    ;; ARMORLEVEL token
    ("\\(\\[\\)\\(ARMORLEVEL\\)\\(:\\)\\(0\\|1\\|2\\|3\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactvalue-face t)
     (5 dfraw-bracket-face t))
    
    ;; MATERIAL_SIZE token
    ("\\(\\[\\)\\(MATERIAL_SIZE\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; nullary tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("METAL_ARMOR_LEVELS"
	  "CHAIN_METAL_TEXT"
	  "SOFT"
	  "HARD"
	  "METAL"
	  "BARRED"
	  "SCALED"
	  "LEATHER"
	  "SHAPED"
	  "STRUCTURAL_ELASTICITY_CHAIN_ALL"
	  "STRUCTURAL_ELASTICITY_CHAIN_METAL"
	  "STRUCTURAL_ELASTICITY_WOVEN_THREAD"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-bracket-face t))
    
    ;; VALUE token
    ("\\(\\[\\)\\(VALUE\\)\\(:\\)\\(-?[0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; PREPLURAL and MATERIAL_PLACEHOLDER tokens
    ("\\(\\[\\)\\(PREPLURAL\\|MATERIAL_PLACEHOLDER\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-string-face t)
     (5 dfraw-bracket-face t))
    
    ;; *STEP tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("UPSTEP"
	  "UBSTEP"
	  "LBSTEP"))
       "\\)\\(:\\)\\(MAX\\|[0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; LAYER_* tokens
    ("\\(\\[\\)\\(LAYER_\\(?:SIZE\\|PERMIT\\)\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; LAYER token
    (,(concat
       "\\(\\[\\)\\(LAYER\\)\\(:\\)\\("
       (regexp-opt
	'("UNDER"
	  "OVER"
	  "ARMOR"
	  "COVER"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-bracket-face t))
    
    ;; BLOCKCHANCE token
    ("\\(\\[\\)\\(BLOCKCHANCE\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; COVERAGE token
    ("\\(\\[\\)\\(COVERAGE\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;;; TOOL subtokens

    ;; NAME, ATTACK, and ATTACK_PREPARE_AND_RECOVER tokens are already covered by AMMO
    ;; VALUE, MATERIAL_SIZE, SIZE, and WEIGHT tokens are already covered by ARMOR
    
    ;; nullary tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("BONE_MAT"
	  "CERAMIC_MAT"
	  "GLASS_MAT"
	  "HARD_MAT"
	  "LEATHER_MAT"
	  "METAL_MAT"
	  "METAL_WEAPON_MAT"
	  "SHEET_MAT"
	  "SHELL_MAT"
	  "SILK_MAT"
	  "SOFT_MAT"
	  "STONE_MAT"
	  "THREAD_PLANT_MAT"
	  "WOOD_MAT"
	  "INCOMPLETE_ITEM"
	  "UNIMPROVABLE"
	  "INVERTED_TILE"
	  "NO_DEFAULT_JOB"
	  "FURNITURE"
	  "NO_DEFAULT_IMPROVEMENTS"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-tagtoken-face t)
     (3 dfraw-bracket-face t))
    
    ;; unary tokens with a value argument
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("TILE"
	  "CONTAINER_CAPACITY"
	  "SHOOT_FORCE"
	  "SHOOT_MAXVEL"
	  "TWO_HANDED"
	  "MINIMUM_SIZE"))
       "\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-bracket-face t))
    
    ;; unary tokens with a string argument
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("DESCRIPTION"
	  "ADJECTIVE"))
       "\\)\\(:\\)\\(.+?\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-string-face t)
     (5 dfraw-bracket-face t))
    
    ;; DEFAULT_IMPROVEMENT token (form 1)
    (,(concat
       "\\(\\[\\)\\(DEFAULT_IMPROVEMENT\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\("
       (regexp-opt
	'("BONE_MAT"
	  "CERAMIC_MAT"
	  "GLASS_MAT"
	  "HARD_MAT"
	  "LEATHER_MAT"
	  "METAL_MAT"
	  "METAL_WEAPON_MAT"
	  "SHEET_MAT"
	  "SHELL_MAT"
	  "SILK_MAT"
	  "SOFT_MAT"
	  "STONE_MAT"
	  "THREAD_PLANT_MAT"
	  "WOOD_MAT"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-identifier-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-tagtoken-face t)
     (7 dfraw-bracket-face t))
    
    ;; DEFAULT_IMPROVEMENT token (form 2)
    (,(concat
       "\\(\\[\\)\\(DEFAULT_IMPROVEMENT\\)\\(:\\)\\(SPECIFIC\\)\\(:\\)\\([A-Z0-9_]+\\)\\(:\\)\\("
       (regexp-opt
	'("BONE_MAT"
	  "CERAMIC_MAT"
	  "GLASS_MAT"
	  "HARD_MAT"
	  "LEATHER_MAT"
	  "METAL_MAT"
	  "METAL_WEAPON_MAT"
	  "SHEET_MAT"
	  "SHELL_MAT"
	  "SILK_MAT"
	  "SOFT_MAT"
	  "STONE_MAT"
	  "THREAD_PLANT_MAT"
	  "WOOD_MAT"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-exactstring-face t)
     (7 dfraw-colon-face t)
     (8 dfraw-tagtoken-face t)
     (9 dfraw-bracket-face t))
    
    ;; TOOL_USE token
    (,(concat
       "\\(\\[\\)\\(TOOL_USE\\)\\(:\\)\\("
       (regexp-opt
	'("LIQUID_COOKING"
	  "LIQUID_SCOOP"
	  "GRIND_POWDER_RECEPTACLE"
	  "GRIND_POWDER_GRINDER"
	  "MEAT_CARVING"
	  "MEAT_BONING"
	  "MEAT_SLICING"
	  "MEAT_CLEAVING"
	  "HOLD_MEAT_FOR_CARVING"
	  "MEAL_CONTAINER"
	  "NEST_BOX"
	  "LIQUID_CONTAINER"
	  "FOOD_STORAGE"
	  "HIVE"
	  "SMALL_OBJECT_STORAGE"
	  "TRACK_CART"
	  "HEAVY_OBJECT_HAULING"
	  "STAND_AND_WORK_ABOVE"
	  "ROLL_UP_SHEET"
	  "PROTECT_FOLDED_SHEETS"
	  "CONTAIN_WRITING"
	  "BOOKCASE"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-bracket-face t))
    
    ;; SKILL token
    (,(concat
       "\\(\\[\\)\\(SKILL\\)\\(:\\)\\("
       (regexp-opt
	'("MINING"
	  "WOODCUTTING"
	  "CARPENTRY"
	  "DETAILSTONE"
	  "MASONRY"
	  "ANIMALTRAIN"
	  "ANIMALCARE"
	  "DISSECT_FISH"
	  "PROCESSFISH"
	  "BUTCHER"
	  "TRAPPING"
	  "TANNER"
	  "WEAVING"
	  "BREWING"
	  "ALCHEMY"
	  "CLOTHESMAKING"
	  "MILLING"
	  "PROCESSPLANTS"
	  "CHEESEMAKING"
	  "MILK"
	  "COOK"
	  "PLANT"
	  "HERBALISM"
	  "FISH"
	  "SMELT"
	  "EXTRACT_STRAND"
	  "FORGE_WEAPON"
	  "FORGE_ARMOR"
	  "FORGE_FURNITURE"
	  "CUTGEM"
	  "ENCRUSTGEM"
	  "WOODCRAFT"
	  "STONECRAFT"
	  "METALCRAFT"
	  "GLASSMAKER"
	  "LEATHERWORK"
	  "BONECARVE"
	  "AXE"
	  "SWORD"
	  "DAGGER"
	  "MACE"
	  "HAMMER"
	  "SPEAR"
	  "CROSSBOW"
	  "SHIELD"
	  "ARMOR"
	  "SIEGECRAFT"
	  "SIEGEOPERATE"
	  "BOWYER"
	  "PIKE"
	  "WHIP"
	  "BOW"
	  "BLOWGUN"
	  "THROW"
	  "MECHANICS"
	  "MAGIC_NATURE"
	  "SNEAK"
	  "DESIGNBUILDING"
	  "DRESS_WOUNDS"
	  "DIAGNOSE"
	  "SURGERY"
	  "SET_BONE"
	  "SUTURE"
	  "CRUTCH_WALK"
	  "WOOD_BURNING"
	  "LYE_MAKING"
	  "SOAP_MAKING"
	  "POTASH_MAKING"
	  "DYER"
	  "OPERATE_PUMP"
	  "SWIMMING"
	  "PERSUASION"
	  "NEGOTIATION"
	  "JUDGING_INTENT"
	  "APPRAISAL"
	  "ORGANIZATION"
	  "RECORD_KEEPING"
	  "LYING"
	  "INTIMIDATION"
	  "CONVERSATION"
	  "COMEDY"
	  "FLATTERY"
	  "CONSOLE"
	  "PACIFY"
	  "TRACKING"
	  "KNOWLEDGE_ACQUISITION"
	  "CONCENTRATION"
	  "DISCIPLINE"
	  "SITUATIONAL_AWARENESS"
	  "WRITING"
	  "PROSE"
	  "POETRY"
	  "READING"
	  "SPEAKING"
	  "COORDINATION"
	  "BALANCE"
	  "LEADERSHIP"
	  "TEACHING"
	  "MELEE_COMBAT"
	  "RANGED_COMBAT"
	  "WRESTLING"
	  "BITE"
	  "GRASP_STRIKE"
	  "STANCE_STRIKE"
	  "DODGING"
	  "MISC_WEAPON"
	  "KNAPPING"
	  "MILITARY_TACTICS"
	  "SHEARING"
	  "SPINNING"
	  "POTTERY"
	  "GLAZING"
	  "PRESSING"
	  "BEEKEEPING"
	  "WAX_WORKING"
	  "CLIMBING"
	  "GELD"
	  "DANCE"
	  "MAKE_MUSIC"
	  "SING"
	  "PLAY_KEYBOARD_INSTRUMENT"
	  "PLAY_STRINGED_INSTRUMENT"
	  "PLAY_WIND_INSTRUMENT"
	  "PLAY_PERCUSSION_INSTRUMENT"
	  "CRITICAL_THINKING"
	  "LOGIC"
	  "MATHEMATICS"
	  "ASTRONOMY"
	  "CHEMISTRY"
	  "GEOGRAPHY"
	  "OPTICS_ENGINEER"
	  "FLUID_ENGINEER"
	  "PAPERMAKING"
	  "BOOKBINDING"))
       "\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-bracket-face t))
    
    ;; RANGED token
    (,(concat
       "\\(\\[\\)\\(RANGED\\)\\(:\\)\\("
       (regexp-opt
	'("MINING"
	  "WOODCUTTING"
	  "CARPENTRY"
	  "DETAILSTONE"
	  "MASONRY"
	  "ANIMALTRAIN"
	  "ANIMALCARE"
	  "DISSECT_FISH"
	  "PROCESSFISH"
	  "BUTCHER"
	  "TRAPPING"
	  "TANNER"
	  "WEAVING"
	  "BREWING"
	  "ALCHEMY"
	  "CLOTHESMAKING"
	  "MILLING"
	  "PROCESSPLANTS"
	  "CHEESEMAKING"
	  "MILK"
	  "COOK"
	  "PLANT"
	  "HERBALISM"
	  "FISH"
	  "SMELT"
	  "EXTRACT_STRAND"
	  "FORGE_WEAPON"
	  "FORGE_ARMOR"
	  "FORGE_FURNITURE"
	  "CUTGEM"
	  "ENCRUSTGEM"
	  "WOODCRAFT"
	  "STONECRAFT"
	  "METALCRAFT"
	  "GLASSMAKER"
	  "LEATHERWORK"
	  "BONECARVE"
	  "AXE"
	  "SWORD"
	  "DAGGER"
	  "MACE"
	  "HAMMER"
	  "SPEAR"
	  "CROSSBOW"
	  "SHIELD"
	  "ARMOR"
	  "SIEGECRAFT"
	  "SIEGEOPERATE"
	  "BOWYER"
	  "PIKE"
	  "WHIP"
	  "BOW"
	  "BLOWGUN"
	  "THROW"
	  "MECHANICS"
	  "MAGIC_NATURE"
	  "SNEAK"
	  "DESIGNBUILDING"
	  "DRESS_WOUNDS"
	  "DIAGNOSE"
	  "SURGERY"
	  "SET_BONE"
	  "SUTURE"
	  "CRUTCH_WALK"
	  "WOOD_BURNING"
	  "LYE_MAKING"
	  "SOAP_MAKING"
	  "POTASH_MAKING"
	  "DYER"
	  "OPERATE_PUMP"
	  "SWIMMING"
	  "PERSUASION"
	  "NEGOTIATION"
	  "JUDGING_INTENT"
	  "APPRAISAL"
	  "ORGANIZATION"
	  "RECORD_KEEPING"
	  "LYING"
	  "INTIMIDATION"
	  "CONVERSATION"
	  "COMEDY"
	  "FLATTERY"
	  "CONSOLE"
	  "PACIFY"
	  "TRACKING"
	  "KNOWLEDGE_ACQUISITION"
	  "CONCENTRATION"
	  "DISCIPLINE"
	  "SITUATIONAL_AWARENESS"
	  "WRITING"
	  "PROSE"
	  "POETRY"
	  "READING"
	  "SPEAKING"
	  "COORDINATION"
	  "BALANCE"
	  "LEADERSHIP"
	  "TEACHING"
	  "MELEE_COMBAT"
	  "RANGED_COMBAT"
	  "WRESTLING"
	  "BITE"
	  "GRASP_STRIKE"
	  "STANCE_STRIKE"
	  "DODGING"
	  "MISC_WEAPON"
	  "KNAPPING"
	  "MILITARY_TACTICS"
	  "SHEARING"
	  "SPINNING"
	  "POTTERY"
	  "GLAZING"
	  "PRESSING"
	  "BEEKEEPING"
	  "WAX_WORKING"
	  "CLIMBING"
	  "GELD"
	  "DANCE"
	  "MAKE_MUSIC"
	  "SING"
	  "PLAY_KEYBOARD_INSTRUMENT"
	  "PLAY_STRINGED_INSTRUMENT"
	  "PLAY_WIND_INSTRUMENT"
	  "PLAY_PERCUSSION_INSTRUMENT"
	  "CRITICAL_THINKING"
	  "LOGIC"
	  "MATHEMATICS"
	  "ASTRONOMY"
	  "CHEMISTRY"
	  "GEOGRAPHY"
	  "OPTICS_ENGINEER"
	  "FLUID_ENGINEER"
	  "PAPERMAKING"
	  "BOOKBINDING"))
       "\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-exactstring-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-identifier-face t)
     (7 dfraw-bracket-face t))

    ;;; GRAPHICS subtokens
    
    ;; TILE_PAGE token
    ("\\(\\[\\)\\(TILE_PAGE\\)\\(:\\)\\([A-Z0-9_]+\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-objectidentifier-face t)
     (5 dfraw-bracket-face t))
    
    ;; FILE token
    ("\\(\\[\\)\\(FILE\\)\\(:\\)\\(.+?\\)\\(\\]\\)"
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-file-path-face t)
     (5 dfraw-bracket-face t))
    
    ;; *_DIM tokens
    (,(concat
       "\\(\\[\\)\\("
       (regexp-opt
	'("TILE_DIM"
	  "PAGE_DIM"))
       "\\)\\(:\\)\\([0-9]+\\)\\(:\\)\\([0-9]+\\)\\(\\]\\)")
     (1 dfraw-bracket-face t)
     (2 dfraw-token-face t)
     (3 dfraw-colon-face t)
     (4 dfraw-value-face t)
     (5 dfraw-colon-face t)
     (6 dfraw-value-face t)
     (7 dfraw-bracket-face t))

    ;; TODO: the graphics specifier tokens

    ;;; 
    
    )
  "Token-specific font-lock matchers for Dwarf Fortress \"raw\" files.")

(defconst dfraw-font-lock-level1 (append dfraw-font-lock-exocomment-header
					 dfraw-font-lock-basic)
  "Font-lock level 1 for Dwarf Fortress \"raw\" files.")

(defconst dfraw-font-lock-level2 (append dfraw-font-lock-level1
					 dfraw-font-lock-token-specific)
  "Font-lock level 2 for Dwarf Fortress \"raw\" files.")

;;;###autoload
(define-derived-mode dfraw-mode
  fundamental-mode "DFRaw"
  "Major mode for working with Dwarf Fortress \"raw\" files."
  (setq-local font-lock-defaults '((dfraw-font-lock-level1
				    dfraw-font-lock-level2)
				   t)))

(provide 'dfraw-mode)

;;; dfraw-mode.el ends here
