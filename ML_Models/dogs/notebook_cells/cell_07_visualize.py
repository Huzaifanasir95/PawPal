# Visualize class distribution
fig, axes = plt.subplots(2, 2, figsize=(18, 12))

counts = list(class_counts.values())

# 1. Histogram
ax = axes[0, 0]
ax.hist(counts, bins=50, color='skyblue', edgecolor='black', alpha=0.7)
ax.set_xlabel('Number of Images per Class', fontsize=12)
ax.set_ylabel('Number of Classes', fontsize=12)
ax.set_title('Class Distribution Histogram', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# 2. Top 15 vs Bottom 15 breeds
ax = axes[0, 1]
sorted_counts = sorted(class_counts.items(), key=lambda x: x[1])
bottom_15 = sorted_counts[:15]
top_15 = sorted_counts[-15:]
combined = bottom_15 + [('---SEPARATOR---', 0)] + top_15
breeds = [b[0][:25] for b in combined]  # Truncate long names
values = [b[1] for b in combined]
colors = ['#ff4444']*15 + ['white'] + ['#44ff44']*15
ax.barh(range(len(breeds)), values, color=colors, edgecolor='black', alpha=0.7)
ax.set_yticks(range(len(breeds)))
ax.set_yticklabels(breeds, fontsize=8)
ax.set_xlabel('Number of Images', fontsize=12)
ax.set_title('Most vs Least Common Breeds', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3, axis='x')

# 3. Box plot
ax = axes[1, 0]
bp = ax.boxplot(counts, vert=False, patch_artist=True)
bp['boxes'][0].set_facecolor('lightblue')
ax.set_xlabel('Number of Images per Class', fontsize=12)
ax.set_title('Distribution Box Plot', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# 4. Statistics summary
ax = axes[1, 1]
ax.axis('off')
stats_text = f"""
STANFORD DOGS DATASET
{'='*42}

Total Breeds: {len(class_counts)}
Total Images: {sum(counts):,}

Images per Breed:
  • Minimum: {min(counts)}
  • Maximum: {max(counts)}
  • Mean: {np.mean(counts):.1f}
  • Median: {np.median(counts):.1f}
  • Std Dev: {np.std(counts):.1f}

Imbalance Ratio: {max(counts)/max(min(counts), 1):.1f}:1
Status: {'✅ Well-Balanced!' if max(counts)/max(min(counts), 1) < 3 else '⚠️ Moderate Imbalance'}

{'='*42}
TRAINING STRATEGY:
{'='*42}

✓ ConvNeXt V2 Base (88M params)
✓ Focal Loss (γ={config.FOCAL_GAMMA})
✓ Advanced Augmentation
✓ Progressive Training (4 stages)
✓ Test-Time Augmentation
✓ MixUp & CutMix

Target: 92-95% Accuracy
"""
ax.text(0.05, 0.95, stats_text, transform=ax.transAxes,
       fontsize=10, verticalalignment='top',
       fontfamily='monospace',
       bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig(os.path.join(config.OUTPUT_DIR, 'class_distribution.png'), 
            dpi=150, bbox_inches='tight')
plt.show()

print("\n📊 Visualization saved to:", os.path.join(config.OUTPUT_DIR, 'class_distribution.png'))
