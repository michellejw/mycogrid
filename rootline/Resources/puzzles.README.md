# puzzles.json — generated bundle

Do **not** hand-edit. The app's date→puzzle mapping depends on array order being
append-only: when extending, only *append* to a tier's array; never reorder or
remove entries.

Regenerate (drift guard — should reproduce byte-for-byte):

    BIN=scripts/MycogridSolver/.build/release/mycogrid-generate
    swift build -c release --package-path scripts/MycogridSolver --product mycogrid-generate
    $BIN --seed 1 --count 200 --tier sprout    --out /tmp/mycogrid-gen/sprout.json
    $BIN --seed 1 --count 200 --tier mycelium  --out /tmp/mycogrid-gen/mycelium.json
    $BIN --seed 1 --count 100 --tier ancient   --out /tmp/mycogrid-gen/ancient.json
    $BIN --seed 1 --count 200 --tier oldGrowth --out /tmp/mycogrid-gen/oldGrowth.json
    jq -s '{version:1, tiers:(reduce .[] as $f ({}; . + $f.tiers))}' \
      /tmp/mycogrid-gen/{sprout,mycelium,ancient,oldGrowth}.json > rootline/Resources/puzzles.json

Validate:

    swift run -c release --package-path scripts/MycogridSolver \
      mycogrid-validate bundle rootline/Resources/puzzles.json
