class StageConfig {
  final int stageNumber;
  final String name;
  final List<List<int>> grid;

  const StageConfig({
    required this.stageNumber,
    required this.name,
    required this.grid,
  });

  int get rows => grid.length;
  int get cols => grid.isEmpty ? 0 : grid[0].length;

  static const List<StageConfig> all = [
    StageConfig(
      stageNumber: 1,
      name: 'Stage 1: Dawn',
      grid: [
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
      ],
    ),
    StageConfig(
      stageNumber: 2,
      name: 'Stage 2: Dusk',
      grid: [
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 2, 1, 2, 2, 1, 2, 1],
        [2, 2, 2, 2, 2, 2, 2, 2],
        [1, 2, 1, 2, 2, 1, 2, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
      ],
    ),
    StageConfig(
      stageNumber: 3,
      name: 'Stage 3: Storm',
      grid: [
        [1, 1, 2, 1, 1, 1, 2, 1, 1],
        [1, 2, 2, 2, 1, 2, 2, 2, 1],
        [2, 2, 3, 2, 2, 2, 3, 2, 2],
        [1, 2, 2, 2, 1, 2, 2, 2, 1],
        [1, 1, 2, 1, 3, 1, 2, 1, 1],
      ],
    ),
    StageConfig(
      stageNumber: 4,
      name: 'Stage 4: Thunder',
      grid: [
        [1, 1, 1, 2, 1, 2, 1, 1, 1],
        [1, 2, 2, 2, 3, 2, 2, 2, 1],
        [2, 2, 3, 3, 3, 3, 3, 2, 2],
        [2, 3, 3, 3, 2, 3, 3, 3, 2],
        [1, 2, 2, 2, 3, 2, 2, 2, 1],
        [1, 1, 2, 1, 2, 1, 2, 1, 1],
      ],
    ),
    StageConfig(
      stageNumber: 5,
      name: 'Stage 5: Blaze',
      grid: [
        [0, 0, 1, 1, 2, 2, 1, 1, 0, 0],
        [0, 1, 2, 2, 3, 3, 2, 2, 1, 0],
        [1, 2, 3, 3, 3, 3, 3, 3, 2, 1],
        [1, 2, 3, 3, 3, 3, 3, 3, 2, 1],
        [0, 1, 2, 2, 3, 3, 2, 2, 1, 0],
        [0, 0, 1, 1, 2, 2, 1, 1, 0, 0],
      ],
    ),
    StageConfig(
      stageNumber: 6,
      name: 'Stage 6: Fortress',
      grid: [
        [3, 0, 3, 0, 3, 3, 0, 3, 0, 3],
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
        [2, 3, 2, 3, 2, 2, 3, 2, 3, 2],
        [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
        [1, 2, 1, 2, 1, 1, 2, 1, 2, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 1, 0, 1, 1, 0, 1, 0, 1],
      ],
    ),
    StageConfig(
      stageNumber: 7,
      name: 'Stage 7: Nexus',
      grid: [
        [3, 1, 1, 1, 1, 1, 1, 1, 1, 3],
        [1, 3, 2, 1, 1, 1, 1, 2, 3, 1],
        [1, 2, 3, 2, 1, 1, 2, 3, 2, 1],
        [1, 1, 2, 3, 2, 2, 3, 2, 1, 1],
        [1, 2, 3, 2, 1, 1, 2, 3, 2, 1],
        [1, 3, 2, 1, 1, 1, 1, 2, 3, 1],
        [3, 1, 1, 1, 1, 1, 1, 1, 1, 3],
      ],
    ),
    StageConfig(
      stageNumber: 8,
      name: 'Stage 8: Pyramid',
      grid: [
        [0, 0, 0, 0, 3, 3, 0, 0, 0, 0],
        [0, 0, 0, 3, 3, 3, 3, 0, 0, 0],
        [0, 0, 3, 3, 2, 2, 3, 3, 0, 0],
        [0, 3, 3, 2, 2, 2, 2, 3, 3, 0],
        [3, 3, 2, 2, 1, 1, 2, 2, 3, 3],
        [3, 2, 2, 1, 1, 1, 1, 2, 2, 3],
        [2, 2, 1, 1, 1, 1, 1, 1, 2, 2],
        [2, 1, 1, 1, 1, 1, 1, 1, 1, 2],
      ],
    ),
    StageConfig(
      stageNumber: 9,
      name: 'Stage 9: Chaos',
      grid: [
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
        [3, 2, 3, 2, 3, 3, 2, 3, 2, 3],
        [2, 3, 2, 3, 2, 2, 3, 2, 3, 2],
        [3, 2, 3, 2, 3, 3, 2, 3, 2, 3],
        [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
        [3, 2, 3, 2, 3, 3, 2, 3, 2, 3],
        [2, 3, 2, 3, 2, 2, 3, 2, 3, 2],
        [3, 2, 3, 2, 3, 3, 2, 3, 2, 3],
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      ],
    ),
    StageConfig(
      stageNumber: 10,
      name: 'Stage 10: Apex',
      grid: [
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
        [3, 3, 2, 3, 3, 3, 3, 2, 3, 3],
        [3, 2, 2, 2, 3, 3, 2, 2, 2, 3],
        [3, 3, 2, 3, 3, 3, 3, 2, 3, 3],
        [3, 3, 3, 3, 2, 2, 3, 3, 3, 3],
        [3, 2, 3, 3, 3, 3, 3, 3, 2, 3],
        [2, 3, 2, 3, 3, 3, 3, 2, 3, 2],
        [3, 2, 3, 3, 3, 3, 3, 3, 2, 3],
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      ],
    ),
  ];

  static StageConfig? get(int stageNumber) {
    if (stageNumber < 1 || stageNumber > all.length) return null;
    return all[stageNumber - 1];
  }
}
