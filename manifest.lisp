;;;; manifest.lisp --- Receipe for the site.
;;;;
;;;; Pick your favorite one of these:
;;;;   (:full        "stem")            one photo, full 1200px column
;;;;   (:bleed       "stem" [card [corner [tone]]])   edge to edge, full viewport
;;;;   (:feature :left  "stem" ["wall text"])  photo at ~80%, text/space beside it right
;;;;   (:feature :right "stem" ["wall text"])  photo at ~80%, text/space beside it left
;;;;   (:pair        "stem-a" "stem-b") two photos side by side
;;;;
;;;; STEM needs no extension - just don't put two things in there with the same name.
;;;; Wall text is raw HTML; <em> for the title, <br> for line breaks, &middot; to
;;;; separate title from place/year. These labels are placeholder prose for now.
;;;;
;;;; A :bleed card is a label debossed into a corner of the photo. CORNER is one of
;;;; :bottom-left (default) :bottom-right :top-left :top-right; TONE is :on-dark
;;;; (default) or :on-light, chosen for how bright that corner of the image is.

(:site
 (:page :main
        (:bleed          "DSC_0045" "<em>Overture</em> &middot; Faro, 2018<br>The coast before it decides what to be." :bottom-left :on-dark)
        (:feature :right "DSC_0065" "<em>Salt Index</em> &middot; C&aacute;diz, 2018<br>Where the harbor keeps its ledger in rope and rust.")
        (:bleed          "DSC_0508" "<em>Held Breath</em> &middot; Lofoten, 2019<br>A fjord rehearsing stillness." :bottom-right :on-dark)
        (:feature :left  "DSC_0641" "<em>Meridian, Unmarked</em> &middot; Lisbon, 2019<br>The hour the tiles give back the light they took all afternoon.")
        (:feature :right "DSC_0729" "<em>Third Person Singular</em> &middot; Kyoto, 2020<br>A doorway practicing to be a window.")
        (:feature :left  "DSC00179" "<em>Low Tide Arithmetic</em> &middot; Sligo, 2017<br>Everything the sea subtracts, it returns as edges.")
        (:full           "DSC00474")
        (:bleed          "DSC00590" "<em>The Flat Hour</em> &middot; Camargue, 2017<br>Where the horizon files no complaint." :bottom-left :on-light)
        (:feature :left  "DSC01166" "<em>Interior with Rumor</em> &middot; Marrakech, 2019<br>Shade sold by the meter, bought by the eye.")
        (:feature :right "DSC01668" "<em>Continuo</em> &middot; Vienna, 2016<br>A staircase overheard rather than seen.")
        (:feature :left  "DSC01708" "<em>The Long Consonant</em> &middot; Reykjav&iacute;k, 2018<br>Weather in the second person.")
        (:feature :right "DSC02109-2" "<em>Ferrous Pastoral</em> &middot; Piedmont, 2021<br>A field that rusts before it ripens.")
        (:bleed          "DSC04039" "<em>Ground Truth</em> &middot; Atacama, 2021<br>A place that keeps no weather." :bottom-right :on-dark)
        (:feature :right "DSCF0165" "<em>Notes Toward a Harbor</em> &middot; Valpara&iacute;so, 2019<br>Color used as a form of insurance.")
        (:bleed          "DSCF0287" "<em>Slow Frequency</em> &middot; Hokkaido, 2020<br>Snow doing the listening." :top-left :on-light)
        (:feature :left  "IMG_0476" "<em>Recto / Verso</em> &middot; Porto, 2018<br>The city photographed from its own reflection.")
        (:feature :right "IMG_0916" "<em>Quiet Machinery</em> &middot; Hamburg, 2017<br>An engine at the exact moment of forgetting its purpose.")
        (:feature :left  "IMG_1303" "<em>Afternoon, Declined</em> &middot; Seville, 2019<br>Light rehearsing its exit through a slatted door.")
        (:full           "IMG_1516")
        (:bleed          "IMG_2202" "<em>Long Exposure, Short Day</em> &middot; Troms&oslash;, 2019<br>Light rationed by the season." :bottom-left :on-dark)
        (:feature :right "IMG_2491" "<em>The Understudy</em> &middot; Naples, 2020<br>A wall that has memorized every poster it ever wore.")
        (:feature :left  "IMG_2496" "<em>Ostinato</em> &middot; Bergen, 2016<br>Rain keeping time for a street that will not dance.")
        (:bleed          "IMG_3122" "<em>Undertow</em> &middot; Nazar&eacute;, 2018<br>The sea keeping its own counsel." :bottom-right :on-dark)
        (:feature :right "IMG_3134" "<em>Field Notes, Unsent</em> &middot; Hanoi, 2019<br>The steam that stands in for a sentence.")
        (:feature :left  "IMG_3142" "<em>Provenance Unknown</em> &middot; Trieste, 2017<br>A courtyard that keeps changing its story.")
        (:bleed          "IMG_3157" "<em>Field of View</em> &middot; Tuscany, 2021<br>Distance measured in cypress." :bottom-left :on-light)
        (:full           "IMG_3324")
        (:full           "IMG_3415")
        (:bleed          "IMG_3479" "<em>Coda</em> &middot; Meteora, 2016<br>Stone that decided to keep going." :bottom-left :on-dark)
        (:feature :right "IMG_3624" "<em>Terminal Moraine</em> &middot; Chamonix, 2018<br>What the mountain leaves as a signature.")
        (:feature :left  "IMG_3794" "<em>Sotto Voce</em> &middot; Palermo, 2020<br>A facade explaining itself only to the shade.")
        (:full           "P7141766"))

 (:page :antarctica
        (:full           "DSC01976")
        (:feature :right "DSC02014" "<em>First Person, Plural</em> &middot; Weddell Sea, 2022<br>Ice that agrees with itself in every direction.")
        (:bleed          "DSC02206" "<em>Threshold</em> &middot; Gerlache Strait, 2022<br>The continent's first sentence." :bottom-left :on-light)
        (:feature :left  "DSC02259" "<em>Blue, Load-Bearing</em> &middot; Paradise Harbour, 2022<br>A color old enough to hold weight.")
        (:feature :right "DSC02450" "<em>The Long Argument</em> &middot; Lemaire Channel, 2022<br>Two cliffs that have not spoken in a thousand years.")
        (:feature :left  "DSC02497" "<em>Provisional Coastline</em> &middot; Danco Island, 2022<br>A border redrawn by every tide and believed by none.")
        (:full           "DSC02535")
        (:bleed          "DSC02548" "<em>White Noise</em> &middot; Cuverville Island, 2022<br>Every scale of the same color." :bottom-right :on-light)
        (:feature :left  "DSC02587" "<em>Cathedral, Unconsecrated</em> &middot; Neko Harbour, 2022<br>Architecture with no intention of lasting.")
        (:feature :right "DSC02608" "<em>Silence, Annotated</em> &middot; Wilhelmina Bay, 2022<br>The one sound the cold agrees to carry.")
        (:bleed          "DSC02845" "<em>Last Light, No Night</em> &middot; Lemaire Channel, 2022<br>A dusk the sun refuses to finish." :bottom-left :on-dark)))
